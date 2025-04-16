# tmpfs.py
# tmpfs filesystems
from ..singletons import askyes, write, askyes
from .filesystem import Filesystem

class VFat (Filesystem) :
    def setup (self) :
        lbl = self.name or self.mountpoint.lstrip('/')
        if askyes(f'is {lbl} ({self.device}) bootable ?') :
            write(f'''
            # get partition index :
            PARENTDEV=$(lsblk {self.device} --output PKNAME --noheadings | tr -d '[:blank:]')
            INDEX=$(lsblk {self.device} --output KNAME --noheadings | tr -d '[:blank:]')
            INDEX="${{INDEX:0-1}}"
            sfdisk --part-label /dev/$PARENTDEV $INDEX {lbl}
            parted /dev/$PARENTDEV --script name $INDEX {lbl} \
            set $INDEX boot on\
            set $INDEX esp on
            partprobe &> /dev/null || true
            ''')
