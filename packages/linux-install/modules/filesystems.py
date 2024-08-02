# format and setup btrfs disk based on config
from .question import ask, askyes
from .volumes  import lvm

_NL = '\\n'
_labelpath = '/dev/mapper/'
_btrfsdir  = '/mnt/btrfs/'
    


def _ask_format(dev, mountpoint, fstype, command ) :
        return f'''
        if [ $(blkid {dev} -s TYPE -o value) == "{fstype}" ];
        then
            read -r -p "{dev} ({mountpoint}) already formated as {fstype}, format anyway? [Y/n]" response
            response=${{response,,}}
            if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; 
            then
                {command}
            fi
        else
            {command}
        fi
        '''

class Filesystem :
    def __init__(self, config, fstype) :
        self._config = config
        self._fstype = fstype
        self._fs = []
        self._fs = [fs for name, fs in config.get('fileSystems').items() if fs['fsType'] == fstype]

    def _block(self, f) :
        if f['device'] is not None :
            return f['device']
        else :
            if f['label'] in lvm(self._config).paths :
                return lvm(self._config).paths[f['label']]
            else :
                return f"/dev/mapper/{f['label']}"

    def fformat(self, writer):
        # do not implement
        pass

    def fmount(self, writer) : 
        for f in self._fs :
            dev = self._block(f)
            # fix options   
            opts = list(filter(lambda x: x != 'x-initrd.mount', f['options']))
            mp = f"/mnt{f['mountPoint']}"
            mountpoint = """mount | awk '{if ($3 == "%s") { exit 0}} ENDFILE{exit -1}'""" % mp
            writer.append(f'''
                if $({mountpoint})
                then
                    printf "{_NL}{mp} already mounted"
                else
                    printf "{_NL}mounting {mp}{_NL}"
                    mkdir -p {mp} {dev if 'bind' in opts else ''}
                    mount {'-o ' + ','.join(opts) if len(opts) > 0 else ''} {dev} {mp}
                fi
                ''')
                
class VFat (Filesystem) :
    def __init__(self, config) :
        super().__init__(config, 'vfat')
        
    def fformat(self, writer) :
        for f in self._fs :
            dev = self._block(f)
            lbl = f['label'] or f['mountPoint'].lstrip('/')
            writer.append(_ask_format(dev, lbl, 'vfat', f'''
            printf "{_NL}Formatting {dev} to FAT32{_NL}"
            mkfs.vfat -F 32 {dev}
            '''))
            if askyes(f'is {lbl} ({dev}) bootable ?') :
                writer.append(f'''
                # get partition index :
                PARENTDEV=$(lsblk {dev} --output PKNAME --noheadings | tr -d '[:blank:]')
                INDEX=$(lsblk {dev} --output KNAME --noheadings | tr -d '[:blank:]')
                INDEX="${{INDEX:0-1}}"
                sfdisk --part-label /dev/$PARENTDEV $INDEX {lbl}
                parted /dev/$PARENTDEV --script name $INDEX {lbl} \
                set $INDEX boot on\
                set $INDEX esp on
                ''')

class Btrfs(Filesystem) :
    def __init__(self, config) :
        super().__init__(config, 'btrfs')

    def _listblocks(self) :
        blocks = []
        for f in self._fs :
            blocks.append(self._block(f))
        return sorted(list(set([x for x in blocks if x is not None])))
        
    def fformat(self, writer) :
        # block to label memory
        bdict = {}
        # format and mount all blocks
        for b in self._listblocks() :
            forceformat = askyes(f'erase {b} to blank btrfs', False)
            label = ask(f'what btrfs label for {b} ?', r'[a-z0-9\-_]+')
            bdict[b] = label
            if forceformat :
                writer.append(f'mkfs.btrfs -f -L {label} {b}')
            else :
                writer.append(_ask_format(b, label, 'btrfs', f'mkfs.btrfs -f -L {label} {b}'))
            mp = f'{_btrfsdir}{label}'
            writer.append(f'''
                umount {b} || true
                mkdir -p  {mp}
                mount {b} {mp}
            ''')
        # mount and create all subvolume
        subvols = []
        for f in self._fs :
            subvol = ''
            for opt in f['options'] : 
                if 'subvol' in opt : 
                    subvol = opt.removeprefix('subvol=')
                    break
            if subvol in subvols or subvol == '':
                continue
            subvols.append(subvol)
            mnt = f"{_btrfsdir}{bdict[self._block(f)]}{subvol}"
            writer.append(f'''
                printf "{_NL}creating subvolume {subvol} ({mnt}) {_NL}"
                btrfs subvolume create {mnt}
                btrfs subvolume snapshot  {mnt} {mnt}@blank
            ''')
        # unmount all block devices to mount subvolumes independantly
        for b in self._listblocks() :
            writer.append(f'umount {_btrfsdir}{bdict[b]}')

class ZFS(Filesystem) :
    def __init__(self) :
        # first detect present zfs pools :
        # zpool create {poolname} {mirror} {devices}
        raise NotImplementedError("ZFS format is not implemented yet")

class Tmpfs(Filesystem) :
    def __init__(self, config) :
        super().__init__(config,'tmpfs')
    
    def fmount(self, writer) :
        for f in self._fs :
            dev = self._block(f)
            opts = list(filter(lambda x: x != 'x-initrd.mount', f['options']))
            writer.append(f'''
                printf "{_NL}mounting {f['mountPoint']}{_NL}"
                mkdir -p {f['mountPoint']} {dev if 'mount' in opts else ''}
                mount -t tmpfs {'-o ' + ','.join(opts) if len(opts) > 0 else ''} {dev} {f['mountPoint']}
            ''')
   
class Auto(Filesystem) :
    def __init__(self, config) :
        super().__init__(config, 'auto')