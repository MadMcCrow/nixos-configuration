#!/bin/sh
set -e
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
exit
fi

umount /mnt/var/www &> /dev/null || true
umount /mnt/var/log &> /dev/null || true
umount /mnt/tmp &> /dev/null || true
umount /mnt/etc/ssh &> /dev/null || true
umount /mnt/nix &> /dev/null || true
umount /mnt/home &> /dev/null || true
umount /mnt/boot &> /dev/null || true
umount /mnt/ &> /dev/null || true
#------------------------------
echo "creating LUKS devices"
    
printf "\ncreating luks encrypted drive [0;35;3mcryptroot[0m\n"
cryptsetup --verbose luksFormat --verify-passphrase /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03     

printf "\ncreating luks encrypted drive [0;35;3mcryptserver[0m\n"
cryptsetup --verbose luksFormat --verify-passphrase /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae     

#------------------------------
echo "opening luks devices"
    
if ! [ -e /dev/mapper/cryptroot ]
then
    printf "\nopen luks encrypted drive [0;35;3mcryptroot[0m\n"
    cryptsetup -v luksOpen /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03 cryptroot
fi

if ! [ -e /dev/mapper/cryptserver ]
then
    printf "\nopen luks encrypted drive [0;35;3mcryptserver[0m\n"
    cryptsetup -v luksOpen /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae cryptserver
fi

printf "create LVM2 devices :\n"
    
if [ "$(pvdisplay /dev/mapper/cryptroot 2>/dev/null)" ]
then
    printf "physical volume on /dev/mapper/cryptroot already exists, skipping\n"
else
    pvcreate /dev/mapper/cryptroot
fi
if [ "$(vgdisplay vg_nixos 2>/dev/null)" ]
then
    printf "volume vg_nixos already exists, skipping\n"
else
   vgcreate vg_nixos /dev/mapper/cryptroot
fi
        
if [ "$(lvdisplay /dev/vg_nixos/swap 2>/dev/null)" ]
then
    printf "logical volume swap already exists, skipping\n"
else
     lvcreate -L 16G -n swap vg_nixos
fi
if [ "$(lvdisplay /dev/vg_nixos/nixos 2>/dev/null)" ]
then
    printf "logical volume nixos already exists, skipping\n"
else
     lvcreate -l 100%FREE -n nixos vg_nixos
fi
if (swaplabel /dev/vg_nixos/swap &>/dev/null); then
    printf 'swap detected on  /dev/vg_nixos/swap:'
    swapoff /dev/vg_nixos/swap &> /dev/null || true
else
    printf 'creating swap on  /dev/vg_nixos/swap:'
    mkswap  /dev/vg_nixos/swap
fi
printf ' enabling swap \n'
swapon /dev/vg_nixos/swap
            
if [ $(blkid /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 -s TYPE -o value) == "vfat" ];
then
    read -r -p "/dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 (/boot) already formated as vfat, format anyway? [y/N]" response
    response=${response,,}
    if [[ $response =~ ^(n| ) ]] || [[ -z $response ]]; 
    then
        printf 'skipping format for /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489\n'
    else
        mkfs.vfat /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 1> /dev/null
        partprobe &> /dev/null || true
    fi
else
    mkfs.vfat /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 1> /dev/null
    partprobe &> /dev/null || true
fi

if [ $(blkid /dev/vg_nixos/nixos -s TYPE -o value) == "btrfs" ];
then
    read -r -p "/dev/vg_nixos/nixos (/var/log) already formated as btrfs, format anyway? [y/N]" response
    response=${response,,}
    if [[ $response =~ ^(n| ) ]] || [[ -z $response ]]; 
    then
        printf 'skipping format for /dev/vg_nixos/nixos\n'
    else
        mkfs.btrfs -f -L nixos /dev/vg_nixos/nixos 1> /dev/null
        partprobe &> /dev/null || true
    fi
else
    mkfs.btrfs -f -L nixos /dev/vg_nixos/nixos 1> /dev/null
    partprobe &> /dev/null || true
fi

if [ $(blkid /dev/mapper/cryptserver -s TYPE -o value) == "btrfs" ];
then
    read -r -p "/dev/mapper/cryptserver (/var/www) already formated as btrfs, format anyway? [y/N]" response
    response=${response,,}
    if [[ $response =~ ^(n| ) ]] || [[ -z $response ]]; 
    then
        printf 'skipping format for /dev/mapper/cryptserver\n'
    else
        mkfs.btrfs -f -L serverdata /dev/mapper/cryptserver 1> /dev/null
        partprobe &> /dev/null || true
    fi
else
    mkfs.btrfs -f -L serverdata /dev/mapper/cryptserver 1> /dev/null
    partprobe &> /dev/null || true
fi

# get partition index :
PARENTDEV=$(lsblk /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 --output PKNAME --noheadings | tr -d '[:blank:]')
INDEX=$(lsblk /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 --output KNAME --noheadings | tr -d '[:blank:]')
INDEX="${INDEX:0-1}"
sfdisk --part-label /dev/$PARENTDEV $INDEX /boot
parted /dev/$PARENTDEV --script name $INDEX /boot             set $INDEX boot on            set $INDEX esp on
partprobe &> /dev/null || true

umount /dev/vg_nixos/nixos &> /dev/null || true
mkdir -p  /mnt/btrfs/nixos
mount /dev/vg_nixos/nixos /mnt/btrfs/nixos
            
printf "removing old volume and blank snapshot for /mnt/btrfs/nixos/home\n"
btrfs subvolume delete /mnt/btrfs/nixos/home &> /dev/null || true
rm /mnt/btrfs/nixos/home@blank -rf &> /dev/null || true
printf "creating subvolume /mnt/btrfs/nixos/home (/home) \n"
btrfs subvolume create /mnt/btrfs/nixos/home
btrfs subvolume snapshot  /mnt/btrfs/nixos/home /mnt/btrfs/nixos/home@blank
                

umount /dev/vg_nixos/nixos &> /dev/null || true
mkdir -p  /mnt/btrfs/nixos
mount /dev/vg_nixos/nixos /mnt/btrfs/nixos
            
printf "removing old volume and blank snapshot for /mnt/btrfs/nixos/nix\n"
btrfs subvolume delete /mnt/btrfs/nixos/nix &> /dev/null || true
rm /mnt/btrfs/nixos/nix@blank -rf &> /dev/null || true
printf "creating subvolume /mnt/btrfs/nixos/nix (/nix) \n"
btrfs subvolume create /mnt/btrfs/nixos/nix
btrfs subvolume snapshot  /mnt/btrfs/nixos/nix /mnt/btrfs/nixos/nix@blank
                

umount /dev/vg_nixos/nixos &> /dev/null || true
mkdir -p  /mnt/btrfs/nixos
mount /dev/vg_nixos/nixos /mnt/btrfs/nixos
            
printf "removing old volume and blank snapshot for /mnt/btrfs/nixos/tmp\n"
btrfs subvolume delete /mnt/btrfs/nixos/tmp &> /dev/null || true
rm /mnt/btrfs/nixos/tmp@blank -rf &> /dev/null || true
printf "creating subvolume /mnt/btrfs/nixos/tmp (/tmp) \n"
btrfs subvolume create /mnt/btrfs/nixos/tmp
btrfs subvolume snapshot  /mnt/btrfs/nixos/tmp /mnt/btrfs/nixos/tmp@blank
                

umount /dev/vg_nixos/nixos &> /dev/null || true
mkdir -p  /mnt/btrfs/nixos
mount /dev/vg_nixos/nixos /mnt/btrfs/nixos
            
printf "removing old volume and blank snapshot for /mnt/btrfs/nixos/log\n"
btrfs subvolume delete /mnt/btrfs/nixos/log &> /dev/null || true
rm /mnt/btrfs/nixos/log@blank -rf &> /dev/null || true
printf "creating subvolume /mnt/btrfs/nixos/log (/var/log) \n"
btrfs subvolume create /mnt/btrfs/nixos/log
btrfs subvolume snapshot  /mnt/btrfs/nixos/log /mnt/btrfs/nixos/log@blank
                

printf "mounting /mnt/ root tmpfs\n"
mount -t tmpfs none /mnt/
                
if $(mount | awk '{if ($3 == "/mnt/boot") { exit 0}} ENDFILE{exit -1}')
then
    printf "/mnt/boot already mounted\n"
else
    printf "mounting /mnt/boot\n"
    mkdir -p /mnt/boot 
    mount -o defaults /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 /mnt/boot
fi

if $(mount | awk '{if ($3 == "/mnt/home") { exit 0}} ENDFILE{exit -1}')
then
    printf "/mnt/home already mounted\n"
else
    printf "mounting /mnt/home\n"
    mkdir -p /mnt/home 
    mount -o subvol=/home,lazytime,noatime,compress=zstd /dev/vg_nixos/nixos /mnt/home
fi

if $(mount | awk '{if ($3 == "/mnt/nix") { exit 0}} ENDFILE{exit -1}')
then
    printf "/mnt/nix already mounted\n"
else
    printf "mounting /mnt/nix\n"
    mkdir -p /mnt/nix 
    mount -o subvol=/nix,lazytime,noatime,compress=zstd:5 /dev/vg_nixos/nixos /mnt/nix
fi

if $(mount | awk '{if ($3 == "/mnt/etc/ssh") { exit 0}} ENDFILE{exit -1}')
then
    printf "/mnt/etc/ssh already mounted\n"
else
    printf "mounting /mnt/etc/ssh\n"
    mkdir -p /mnt/etc/ssh
    mkdir -p /nix/persist/ssh
    mount -o bind /nix/persist/ssh /mnt/etc/ssh
fi
            
if $(mount | awk '{if ($3 == "/mnt/tmp") { exit 0}} ENDFILE{exit -1}')
then
    printf "/mnt/tmp already mounted\n"
else
    printf "mounting /mnt/tmp\n"
    mkdir -p /mnt/tmp 
    mount -o subvol=/tmp,lazytime,noatime,nodatacow /dev/vg_nixos/nixos /mnt/tmp
fi

if $(mount | awk '{if ($3 == "/mnt/var/log") { exit 0}} ENDFILE{exit -1}')
then
    printf "/mnt/var/log already mounted\n"
else
    printf "mounting /mnt/var/log\n"
    mkdir -p /mnt/var/log 
    mount -o subvol=/log,compress=zstd:6 /dev/vg_nixos/nixos /mnt/var/log
fi

if $(mount | awk '{if ($3 == "/mnt/var/www") { exit 0}} ENDFILE{exit -1}')
then
    printf "/mnt/var/www already mounted\n"
else
    printf "mounting /mnt/var/www\n"
    mkdir -p /mnt/var/www 
    mount -o compress=zstd:6,noatime /dev/mapper/cryptserver /mnt/var/www
fi

echo "starting nixos install :"
TMPDIR=/mnt/tmp nixos-install --flake github:MadMcCrow/nixos-configuration#terminus --no-root-passwd
    
