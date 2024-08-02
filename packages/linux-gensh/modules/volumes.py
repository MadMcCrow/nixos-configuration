# Handle logical volumes
from .question import ask, askyes
# for f-strings
_NL = '\\n'

def lvm(config) :
    global _lvm
    try :
        return _lvm
    except NameError:
        _lvm = LogicalVolumes(config)
    return _lvm

def crypt(config) : 
    global _crypt
    try :
        return _crypt
    except NameError:
        _crypt = Cryptsetup(config)
    return _crypt
    
def format_luks(config, writer) :
    crypt(config).format_luks(writer)

def open_luks(config, writer) :
    crypt(config).open_luks(writer)

def create_lvm(config, writer) :
    lvm(config).create_lvm(writer)


class Cryptsetup :
    def __init__(self, config) :
        nixluks = config.get('boot.initrd.luks.devices')
        self.luks = list(([(x, nixluks[x]) for x in set(nixluks.keys())]))
    
    def format_luks(self, writer) :
        '''
            format luks drives
        '''
        if len(self.luks) <= 0 :
            return
        for vn, vd in self.luks :
            dev = vd['device']
            print(f"will create luks volume \x1b[0;35;3m{vn}\x1b[0m on device \x1b[0;35;3m{dev}\x1b[0m")
            if askyes(f'Force recreate {vn} ? (this will erase everything)', False) :
                writer.append(f'''
                printf "{_NL}creating luks encrypted drive \e[0;35;3m{vn}\e[0m{_NL}"
                cryptsetup --verbose luksFormat --verify-passphrase {dev}     
                ''')
            else :
                writer.append(f'''
                TYPE=$(blkid {dev} -s TYPE -o value)
                if ! [ -e /dev/mapper/{vn} ]
                then
                if [ $TYPE == "crypto_LUKS" ]
                then
                    printf "{_NL}luks encrypted drive \e[0;35;3m{vn}\e[0m already exists, trying to open it{_NL}"
                    cryptsetup -v luksClose {vn} &> /dev/null || true
                    if cryptsetup -v luksOpen {dev} {vn}
                    then
                        printf "{_NL}luks encrypted drive \e[0;35;3m{vn}\e[0m successfully decrypted{_NL}"
                    else
                        printf "{_NL}rebuilding luks encrypted drive \e[0;35;3m{vn}\e[0m{_NL}"
                        cryptsetup --verbose luksFormat --verify-passphrase {dev}
                    fi
                else
                    printf "{_NL}creating luks encrypted drive \e[0;35;3m{vn}\e[0m{_NL}"
                    cryptsetup --verbose luksFormat --verify-passphrase {dev}          
                fi
                fi
                ''')
        self.open_luks(writer)

    def open_luks(self, writer) :
        '''
            open luks encrypted drives
        '''
        for vn, vd in self.luks :
            writer.append(f'''
            if ! [ -e /dev/mapper/{vn} ]
            then
                printf "{_NL}open luks encrypted drive \e[0;35;3m{vn}\e[0m{_NL}"
                cryptsetup -v luksOpen {vd['device']} {vn}
            fi
            ''')

class LogicalVolumes:
    def __init__(self, config) :
        '''
            get the list of lvms used in config
        '''
        nixluks = config.get('boot.initrd.luks.devices')
        luks = list(([(x, nixluks[x]) for x in set(nixluks.keys())]))
        filesystems = [x for x in config.get('fileSystems').values()]
        swapdevices = [x for x in config.get('swapDevices')]
        lvms = []
        for dev in (filesystems + swapdevices) :
            try:
                if dev['device'] in map (lambda x: x[1]['device'], luks) :
                    continue
                for prefix in ['/dev/disk/by-label', '/dev/mapper/'] :
                    if dev['device'].startswith(prefix) :
                        self.lvms.append(block.removeprefix(prefix))
                    else :
                        continue # not an lvm block device
            except : 
                if dev['label'] in map (lambda x: x[0], luks) :
                    continue
                lvms.append(dev['label'])
        lvms = sorted(list(set(lvms)))
        if len(lvms) <= 0 :
            return
        self._vgs  = {}
        self._lvs  = {}
        self.paths = {}
        while len(lvms) > 0 :
            if len(lvms) > 1 :
                for idx in range(len(lvms)) :
                    print(f'{idx} - {lvms[idx]}')
                num = int(ask('what volume to build first', f'[0-{min(len(lvms)-1,9)}]', '0'))
                lvname = lvms[num]
            else :
                lvname = lvms[0]
            print(f'LVM block {lvname} :')
            # block device
            try :
                block = ask(f'what is the underlying block device for {lvname} ?', r'/dev/[a-z0-9\-/]+', block)
            except :
                block = ask(f'what is the underlying block device for {lvname} ?', r'/dev/[a-z0-9\-/]+')
            # vg name
            try :
                vgname = ask(f'what is the name of the volume group for {lvname} ?', r'[a-z0-9\-_]+', vgname )
            except :
                vgname = ask(f'what is the name of the volume group for {lvname} ?', r'[a-z0-9\-_]+', 'vg01' )
            # block size
            size = ask(f'what size for {lvname} ?', r'[0-9.]+[MGT]|%(?:FREE|VG)?')
            size = f'-l {size}' if '%' in size else f'-L {size}'
            self._lvs[lvname] = {
                'vg' : vgname,
                'size' : size
            } 
            self._vgs[vgname] = block
            # for other systems :
            self.paths[lvname] = f'/dev/{vgname}/{lvname}'
            lvms.remove(lvname)

    def create_lvm(self, writer) :
        for vgname, block in self._vgs.items()  :
            writer.append(f'''
                if [ "$(pvdisplay {block} 2>/dev/null)" ]
                then
                    printf "physical volume on {block} already exists, skipping{_NL}"
                else
                    pvcreate {block}
                fi
                if [ "$(vgdisplay {vgname} 2>/dev/null)" ]
                then
                    printf "volume {vgname} already exists, skipping{_NL}"
                else
                   vgcreate {vgname} {block}
                fi
            ''')
        for lvname , lvinfo in self._lvs.items() :
            writer.append(f'''
                if [ "$(lvdisplay {self.paths[lvname]} 2>/dev/null)" ]
                then
                    printf "logical volume {lvname} already exists, skipping{_NL}"
                else
                     lvcreate {lvinfo['size']} -n {lvname} {lvinfo['vg']}
                fi''')