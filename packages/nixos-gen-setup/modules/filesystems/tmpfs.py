# tmpfs.py
# tmpfs filesystems
from ..singletons import write
from .filesystem import Filesystem
from re import search

# for f-strings:
_NL = '\\n'

class Tmpfs(Filesystem) :

    def __init__(self, configdict : dict ) :
        super().__init__(configdict)
        self.device = None

    def mkfs(self) :
        pass # do not format !

    def mount(self) :
        if self.mountpoint == '/' :
            write(f'''
                    printf "mounting /mnt/ root tmpfs{_NL}"
                    mount -t tmpfs none /mnt/
                ''')
        else :
            opts = ['size=${SIZE}G']
            for o in self.options :
                for r in ['x-initrd.mount' r'size=.*'] :
                    if search(r, o) is not None :
                        continue
                opts.append(o)            
            write(f'''
                printf "mounting /mnt{self.mountpoint}{_NL}"
                SIZE=$(free -tg | awk 'END {{print $2}}')
                mkdir -p /mnt{self.mountpoint} {self.device if 'mount' in opts else ''}
                mount -t tmpfs {'-o ' + ','.join(opts) if len(opts) > 0 else ''} none /mnt{self.mountpoint}
            ''')
   