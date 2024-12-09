# Auto.py
# "auto" filesystems
# they are usually nothing but a bind mount 
from ..singletons import write
from .filesystem import Filesystem

_NL = '\\n'

class Auto(Filesystem) :
    def mkfs(self) :
        pass # do not format !
    
    def mount(self):
        if not 'bind' in self.options :
            super().mount()
        else :
            print(f'AUTO BIND MOUNT : {self.device}')
            opts = list(filter(lambda x: x != 'x-initrd.mount', self.options))
            mp = f"/mnt{self.mountpoint}"
            check = """mount | awk '{if ($3 == "%s") { exit 0}} ENDFILE{exit -1}'""" % mp
            write(f'''
                if $({check})
                then
                    printf "{mp} already mounted{_NL}"
                else
                    printf "mounting {mp}{_NL}"
                    mkdir -p {mp}
                    mkdir -p {self.device}
                    mount {'-o ' + ','.join(opts) if len(opts) > 0 else ''} {self.device} {mp}
                fi
            ''')