#!/bin/sh
set -e
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
exit
fi

#------------------------------
echo "unmounting everything from /mnt"
    
umount /mnt/var/www &> /dev/null || true
umount /mnt/var/log &> /dev/null || true
umount /mnt/tmp &> /dev/null || true
umount /mnt/nix &> /dev/null || true
umount /mnt/home &> /dev/null || true
umount /mnt/etc/ssh &> /dev/null || true
umount /mnt/boot &> /dev/null || true
umount /mnt/ &> /dev/null || true
umount /mnt/* &> /dev/null || true
    
#------------------------------
echo "creating luks devices"
    
if ! [ -e /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03 ]
then
    printf "\e[0;31;1mError\e[0m : cannot find disk /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03 : please fix your config !\n"
    return 1 # error
fi
TYPE=$(blkid /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03 -s TYPE -o value)
if ! [ -e /dev/mapper/cryptroot ]
then
if [ $TYPE == "crypto_LUKS" ]
then
    printf "luks encrypted drive \e[0;35;3mcryptroot\e[0m already exists, trying to open it\n"
    cryptsetup -v luksClose cryptroot &> /dev/null || true
    if cryptsetup -v luksOpen /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03 cryptroot
    then
        printf "luks encrypted drive \e[0;35;3mcryptroot\e[0m successfully decrypted\n"
    else
        printf "rebuilding luks encrypted drive \e[0;35;3mcryptroot\e[0m\n"
        cryptsetup --verbose luksFormat --verify-passphrase /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03
    fi
else
    printf "\ncreating luks encrypted drive \e[0;35;3mcryptroot\e[0m\n"
    cryptsetup --verbose luksFormat --verify-passphrase /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03          
fi
fi

if ! [ -e /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae ]
then
    printf "\e[0;31;1mError\e[0m : cannot find disk /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae : please fix your config !\n"
    return 1 # error
fi
TYPE=$(blkid /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae -s TYPE -o value)
if ! [ -e /dev/mapper/cryptserver ]
then
if [ $TYPE == "crypto_LUKS" ]
then
    printf "luks encrypted drive \e[0;35;3mcryptserver\e[0m already exists, trying to open it\n"
    cryptsetup -v luksClose cryptserver &> /dev/null || true
    if cryptsetup -v luksOpen /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae cryptserver
    then
        printf "luks encrypted drive \e[0;35;3mcryptserver\e[0m successfully decrypted\n"
    else
        printf "rebuilding luks encrypted drive \e[0;35;3mcryptserver\e[0m\n"
        cryptsetup --verbose luksFormat --verify-passphrase /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae
    fi
else
    printf "\ncreating luks encrypted drive \e[0;35;3mcryptserver\e[0m\n"
    cryptsetup --verbose luksFormat --verify-passphrase /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae          
fi
fi

if ! [ -e /dev/mapper/cryptroot ]
then
    printf "\nopen luks encrypted drive \e[0;35;3mcryptroot\e[0m\n"
    cryptsetup -v luksOpen /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03 cryptroot
fi

if ! [ -e /dev/mapper/cryptserver ]
then
    printf "\nopen luks encrypted drive \e[0;35;3mcryptserver\e[0m\n"
    cryptsetup -v luksOpen /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae cryptserver
fi

#------------------------------
echo "opening luks devices"
    
if ! [ -e /dev/mapper/cryptroot ]
then
    printf "\nopen luks encrypted drive \e[0;35;3mcryptroot\e[0m\n"
    cryptsetup -v luksOpen /dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03 cryptroot
fi

if ! [ -e /dev/mapper/cryptserver ]
then
    printf "\nopen luks encrypted drive \e[0;35;3mcryptserver\e[0m\n"
    cryptsetup -v luksOpen /dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae cryptserver
fi

#------------------------------
echo "creating lvm partitions"
    
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
#------------------------------
echo "formating drives"
    
if [ $(blkid /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 -s TYPE -o value) == "vfat" ];
then
    read -r -p "/dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 (boot) already formated as vfat, format anyway? [Y/n]" response
    response=${response,,}
    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; 
    then
        
    printf "\nFormatting /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 to FAT32\n"
    mkfs.vfat -F 32 /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489
    partprobe
    
    fi
else
    
    printf "\nFormatting /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 to FAT32\n"
    mkfs.vfat -F 32 /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489
    partprobe
    
fi

# get partition index :
PARENTDEV=$(lsblk /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 --output PKNAME --noheadings | tr -d '[:blank:]')
INDEX=$(lsblk /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 --output KNAME --noheadings | tr -d '[:blank:]')
INDEX="${INDEX:0-1}"
sfdisk --part-label /dev/$PARENTDEV $INDEX boot
parted /dev/$PARENTDEV --script name $INDEX boot                 set $INDEX boot on                set $INDEX esp on

if [ $(blkid /dev/mapper/cryptserver -s TYPE -o value) == "btrfs" ];
then
    read -r -p "/dev/mapper/cryptserver (serverdata) already formated as btrfs, format anyway? [Y/n]" response
    response=${response,,}
    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; 
    then
        mkfs.btrfs -f -L serverdata /dev/mapper/cryptserver
    fi
else
    mkfs.btrfs -f -L serverdata /dev/mapper/cryptserver
fi

umount /dev/mapper/cryptserver || true
mkdir -p  /mnt/btrfs/serverdata
mount /dev/mapper/cryptserver /mnt/btrfs/serverdata
            
mkfs.btrfs -f -L nixos /dev/vg_nixos/nixos
partprobe
                
umount /dev/vg_nixos/nixos || true
mkdir -p  /mnt/btrfs/nixos
mount /dev/vg_nixos/nixos /mnt/btrfs/nixos
            
printf "\ncreating subvolume /home (/mnt/btrfs/nixos/home) \n"
btrfs subvolume create /mnt/btrfs/nixos/home
btrfs subvolume snapshot  /mnt/btrfs/nixos/home /mnt/btrfs/nixos/home@blank
            
printf "\ncreating subvolume /nix (/mnt/btrfs/nixos/nix) \n"
btrfs subvolume create /mnt/btrfs/nixos/nix
btrfs subvolume snapshot  /mnt/btrfs/nixos/nix /mnt/btrfs/nixos/nix@blank
            
printf "\ncreating subvolume /tmp (/mnt/btrfs/nixos/tmp) \n"
btrfs subvolume create /mnt/btrfs/nixos/tmp
btrfs subvolume snapshot  /mnt/btrfs/nixos/tmp /mnt/btrfs/nixos/tmp@blank
            
printf "\ncreating subvolume /log (/mnt/btrfs/nixos/log) \n"
btrfs subvolume create /mnt/btrfs/nixos/log
btrfs subvolume snapshot  /mnt/btrfs/nixos/log /mnt/btrfs/nixos/log@blank
            
umount /mnt/btrfs/serverdata
umount /mnt/btrfs/nixos
#------------------------------
echo "mounting drives"
    
printf "\nmounting /mnt/ root tmpfs\n"
mount -t tmpfs none /mnt/
                
if $(mount | awk '{if ($3 == "/mnt/boot") { exit 0}} ENDFILE{exit -1}')
then
    printf "\n/mnt/boot already mounted"
else
    printf "\nmounting /mnt/boot\n"
    mkdir -p /mnt/boot 
    mount -o defaults /dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489 /mnt/boot
fi

if $(mount | awk '{if ($3 == "/mnt/home") { exit 0}} ENDFILE{exit -1}')
then
    printf "\n/mnt/home already mounted"
else
    printf "\nmounting /mnt/home\n"
    mkdir -p /mnt/home 
    mount -o subvol=/home,lazytime,noatime,compress=zstd /dev/vg_nixos/nixos /mnt/home
fi

if $(mount | awk '{if ($3 == "/mnt/nix") { exit 0}} ENDFILE{exit -1}')
then
    printf "\n/mnt/nix already mounted"
else
    printf "\nmounting /mnt/nix\n"
    mkdir -p /mnt/nix 
    mount -o subvol=/nix,lazytime,noatime,compress=zstd:5 /dev/vg_nixos/nixos /mnt/nix
fi

if $(mount | awk '{if ($3 == "/mnt/tmp") { exit 0}} ENDFILE{exit -1}')
then
    printf "\n/mnt/tmp already mounted"
else
    printf "\nmounting /mnt/tmp\n"
    mkdir -p /mnt/tmp 
    mount -o subvol=/tmp,lazytime,noatime,nodatacow /dev/vg_nixos/nixos /mnt/tmp
fi

if $(mount | awk '{if ($3 == "/mnt/var/log") { exit 0}} ENDFILE{exit -1}')
then
    printf "\n/mnt/var/log already mounted"
else
    printf "\nmounting /mnt/var/log\n"
    mkdir -p /mnt/var/log 
    mount -o subvol=/log,compress=zstd:6 /dev/vg_nixos/nixos /mnt/var/log
fi

if $(mount | awk '{if ($3 == "/mnt/var/www") { exit 0}} ENDFILE{exit -1}')
then
    printf "\n/mnt/var/www already mounted"
else
    printf "\nmounting /mnt/var/www\n"
    mkdir -p /mnt/var/www 
    mount -o compress=zstd:6,noatime /dev/mapper/cryptserver /mnt/var/www
fi

if $(mount | awk '{if ($3 == "/mnt/etc/ssh") { exit 0}} ENDFILE{exit -1}')
then
    printf "\n/mnt/etc/ssh already mounted"
else
    printf "\nmounting /mnt/etc/ssh\n"
    mkdir -p /mnt/etc/ssh /nix/persist/ssh
    mount -o bind /nix/persist/ssh /mnt/etc/ssh
fi

echo "starting nixos install :"
nixos-install --flake github:/MadMcCrow/nixos-configuration#terminus

