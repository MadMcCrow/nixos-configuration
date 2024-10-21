# filesystems/__init__.py
# give function to simplify formatting and mounting all filesystems
from ..singletons import config, write
from .btrfs import Btrfs
from .vfat import VFat
from .tmpfs import Tmpfs
from .auto import Auto

def listfs() :
    return sorted(
        [(fs | {'name': name})  for name, fs in config('fileSystems').items()],
        key=lambda x: x['device'] if not (x['device'] is None or x['device']=='none' or x['device'].startswith('/dev')) else x['mountPoint'])

def umountall() : 
    '''
        unmount every drive before doing anything
    '''
    mps = reversed([x['mountPoint'] for x in listfs()])
    for mp in mps :
        write(f'umount /mnt{mp} &> /dev/null || true')
    
def filesystems() : 
    '''
        build every filesystems, in the correct order
    '''
    # get the list of filesystems
    fss = []
    for fs in listfs() :
        if fs['fsType'] == 'auto' :
            fss.append(Auto(fs))
        elif fs['fsType'] == 'vfat' :
            fss.append(VFat(fs))
        elif fs['fsType'] == 'btrfs' :
            fss.append(Btrfs(fs))
        elif fs['fsType'] == 'tmpfs' :
            fss.append(Tmpfs(fs))
        else :
            print(f"unsupported filesystem : {fs['name']} is {fs['fsType']}")

    # remove those with the same device
    toformat = [f for i, f in enumerate(fss) if f.device not in [y.device for y in fss[i + 1:]]]
    print('turning partitions and block devices into filesystems !')
    for fs in toformat :
        fs.mkfs()
    
    # make sure they have the correct label, data, subvolumes, etc ...
    print("updating labels, subvolumes, etc...")
    for fs in fss :
        fs.setup()

    # now mount them properly :
    for fs in fss :
        fs.mount()

