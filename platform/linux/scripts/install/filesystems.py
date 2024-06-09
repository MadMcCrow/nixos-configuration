
import sh
from config import parse_config

SUPPORTED =  ['vfat', 'vfs', 'zfs', *[f"ext{x}" for x in range(2,5)], 'btrfs'] 

def _find_in_lines(lines, keys) :
    for l in lines.splitlines() :
        if any(map((lambda x: x in l), keys)) : 
            return l
    return None


def list_filesystems( hostname, flake = "." ) -> list :
    config = parse_config("fileSystems", hostname, flake)
    filesystems = [ x for x in config.values() if x['fsType'] in SUPPORTED]
    # sort filesystems so that we alsways start by the parent mount point !
    filesystems.sort(key=lambda x: (x['mountPoint']))
    return filesystems

def ask_ignore(fs) -> bool :
    if path.exists(fs['device']) :
        print(f"detected {fs['device']} [{fs['mountPoint']}]")
        answer = input(f'skip [Y,n] :')
        return not (answer.lower() in ['no', 'n'])


def query_block_device(fs) -> str :
    if not path.exists(fs['device']):
        print(f"could not find device {fs['device']}")
        print("assuming you created the partitions for nixos")
        return input(f"partition to use for {fs['mountPoint']} (ex. /dev/sda1)?")
    else :
       return fs['device']

def get_uuid(fs) -> str :
    if '/dev/disk/by-uuid/' in fs['device'] :
        return fs['device'].removeprefix('/dev/disk/by-uuid/').replace('-','')
    return None

def format_vfat(fs : dict) :
    drive_part = query_block_device(fs)
    uuid = f"-i {get_uuid(fs)}" if get_uuid(fs) is not None else ''
    print(f"vfat disk to create {fs['device']}")
    if not path.exists(drive_part):
        raise OSError(f"partition {drive_part} does not exist")
    sh.exec(f"mkdosfs {uuid} {drive_part}",
    f"Formatting {drive_part} to FAT32")

def format_btrfs(fs : dict) :
    drive_part = query_block_device(fs)
    uuid = f"-i {get_uuid(fs)}" if get_uuid(fs) is not None else ''
    subvol = None
    for opt in fs['options'] :
        if 'subvol' in opt :
            subvol = opt.removeprefix('subvol=')
    drive_part = query_block_device(fs)
    if not path.exists(drive_part):
        raise OSError(f"partition {drive_part} does not exist")
    # get line from blkid
    blkid = _find_in_lines(sh.exec(f"blkid"),[drive_part, 'TYPE=\"btrfs\"'])
    skipmkfs = blkid is not None
    if not skipmkfs :
        sh.exec(f"mkfs.btrfs {drivepart}", f"formatting {drive_part} to btrfs")
    if subvol is not None :
        fsmount = fs['mountPoint'].removesuffix(subvol)
        mountlist = sh.exec("mount")
        print(mountlist)
        _find_in_lines(mountlist, [drive_part])
        sh.exec(f"mount {drive_part} {fsmount}", f"mounting {drive_part} to {fsmount}")
        sh.exec(f"btrfs subvolume create {fsmount}", f"creating subvolume for {fsmount}")
        sh.exec(f"btrfs subvolume snapshot {fsmount} {fsmount}/@blank", f"creating blank snapshot for {fsmount}")

def format_zfs(fs : dict) :
    # first detect present zfs pools :
    # zpool create {poolname} {mirror} {devices}
    pass
    
def format_filesystems( hostname, flake = "." ) :
    filesystems = list_filesystems(hostname, flake)
    for fs in filesystems : 
        if ask_ignore(fs) :
            continue
        match fs['fsType'] : 
            case 'vfat' :
                format_vfat(fs)
            case 'zfs'  :
                format_zfs(fs)
            case 'btrfs'  :
                format_btrfs(fs)
            case _:
                raise ValueError("unsupported filesystem")

def show_filesystems(hostname, flake = ".") :
    filesystems = list_filesystems(hostname, flake)
    print(f"\nfilesystems to build for {hostname}:")
    for fs in filesystems : 
        print (f" - {fs['device']} -> {fs['mountPoint']} : {fs['fsType']}" )
    