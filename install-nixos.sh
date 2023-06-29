#variables
POOLNAME="nixos-pool"
DEVICE="nvme0n1" 
PART="nvme0n1p2"
BOOT="nvme0n1p1"
HOST="NUC-Cloud"
SIZE="4GiB" 
# format drive command

check_block_device()
{
if ! [[ -b "/dev/$1" ]]
then echo -e  "device /dev/$1 does not exist"
exit 1
fi
}

checks()
{
if [ "$EUID" -ne 0 ]
  then echo -e  "Please run as root"
  exit 1
fi
# check devices
check_block_device $DEVICE
}

inputs()
{
read -p 'host name: ' HOST
read -p 'pool name: ' POOLNAME
read -p 'disk device: '   DEVICE
read -p 'nix zfs partition: '     PART
read -p 'boot partition: '        BOOT
read -p 'boot partition size: '   SIZE
}

format() 
{ 
echo -e  "-------- Format drive --------"
sfdisk --wipe   /dev/$DEVICE
wipefs /dev/$DEVICE
sfdisk --delete /dev/$DEVICE
FORMAT="device: /dev/$DEVICE \n/dev/$BOOT : start= 2048, size= $SIZE, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name=\"EFI\" \n/dev/$PART : type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name=\"NIXOS\" \n"
echo -e  "Format with :"
echo -e  $FORMAT | sfdisk /dev/$DEVICE
# set uuid for boot
mkdosfs -i 8001EF00 /dev/$BOOT
}

clean()
{
echo -e  "-------- Clean and delete pool --------"
umount /mnt/boot
umount /mnt
zpool destroy $POOLNAME -f
umount $PART
umount $BOOT
umount $DEVICE
}

zfs_create()
{
echo -e  "-------- Create zfs pool --------"

# create pool
# Create a root
zpool create $POOLNAME $PART
zfs create -p -o mountpoint=legacy $POOLNAME/local/root
zfs snapshot $POOLNAME/local/root@blank
# create various dataset
zfs create -p -o mountpoint=legacy $POOLNAME/local/nix
zfs create -p -o mountpoint=legacy $POOLNAME/safe/home
zfs create -p -o mountpoint=legacy $POOLNAME/safe/persist

}


zfs_mount()
{
echo -e  "-------- mounting zfs pool --------"
mount -t zfs $POOLNAME/local/root /mnt
mkdir /mnt/boot
mount /dev/$BOOT /mnt/boot
mkdir /mnt/nix
mount -t zfs $POOLNAME/local/nix /mnt/nix
mkdir /mnt/home
mount -t zfs $POOLNAME/safe/home /mnt/home
mkdir /mnt/persist
mount -t zfs $POOLNAME/safe/persist /mnt/persist
}

# run 
install_nixos()
{
echo -e  "-------- install nixos flake --------"
cd /mnt
nixos-install --impure --flake github:MadMcCrow/nixos-configuration#$HOST
}

# perform all actions
#inputs
checks
clean
format
zfs_create
zfs_mount
install_nixos
