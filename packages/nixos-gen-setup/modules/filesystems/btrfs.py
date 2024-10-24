# btrfs.py
# support building btrfs
from ..singletons import write, ask, askyes
from .filesystem import Filesystem

# for f-strings
_NL = '\\n'

_btrfs_label = {}

# stored module variable
class Btrfs(Filesystem) :

    def __init__(self, configdict: dict):
        super().__init__(configdict)
        # get btrfs label for block device :
        if  self.device in _btrfs_label :
            self.btrfs_label = _btrfs_label[self.device]
        else :
            self.btrfs_label = ask(f'what btrfs label for {self.device} ?', r'[a-z0-9\-_]+')
            _btrfs_label[self.device] = self.btrfs_label
        # gen subvolume data
        try :
            self.subvol = next(x for x in self.options if 'subvol' in x).removeprefix('subvol=')
        except :
            self.subvol = None

    # override for better mkfs !
    def mkfs_cmd(self) :
        return f'mkfs.btrfs -f -L {self.btrfs_label} {self.device} 1> /dev/null'

    def setup(self) :
        if self.subvol is not None :
            # make sure device is mounted for creation of subvolume 
            mount = f'/mnt/btrfs/{self.btrfs_label}'
            voldir = f'{mount}{self.subvol}'
            write(f'''
                umount {self.device} &> /dev/null || true
                mkdir -p  {mount}
                mount {self.device} {mount}
            ''')
            if askyes(f'recreate subvolume {voldir} ({self.mountpoint}) ?') :
                write(f'''
                    printf "removing old volume and blank snapshot for {voldir}{_NL}"
                    btrfs subvolume delete {voldir} &> /dev/null || true
                    rm {voldir}@blank -rf &> /dev/null || true
                    printf "creating subvolume {voldir} ({self.mountpoint}) {_NL}"
                    btrfs subvolume create {voldir}
                    btrfs subvolume snapshot  {voldir} {voldir}@blank
                ''')
            else :
                write(f'''
                    if [ -d {voldir} ]; then
                        printf "subvolume {voldir} ({self.mountpoint}) already exist {_NL}"
                    else
                        printf "creating subvolume {self.subvol} ({self.mountpoint}) {_NL}"
                        btrfs subvolume create {voldir}
                        btrfs subvolume snapshot -r {voldir} {voldir}@blank
                    fi
                ''')
            write('\n')

           
    
