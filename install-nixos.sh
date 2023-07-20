#!/usr/bin/env sh
#
# install-nixos.sh
#     script to streamline installation on other devices
#     TODO : read steps to perform
#

#variables
HOST="$1"
POOLNAME="$2"
DEVICE="$3"
PART="$4"
BOOT="$5"
SIZE="$6"

# keep base folder of script
FILE=$PWD

# Colors for output
GRE='\033[0;32m'
BLU='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# count characters
ccount() {
    nc=$(echo $1  | sed 's/\\033\[[0-9;]\{1,\}m//g' )
    nn=$(echo $nc | sed 's/\\0//g')
    echo ${#nn}
}

# echo on a dotted line
echo_line() {
  local t=" $1 "
  local l=50
  local c=$(ccount "$1")
  local p=true
  while [ $c -lt $l ]; do
    if $p; then
      t="${t}-"
      p=false
    else
      t="-${t}"
      p=true
    fi
    c=$(( c + 1 ))
  done
  echo -e "$t"
}

# check if device exists
check_block_device()
{
if ! [ -b "/dev/$1" ]; then
echo -e  "device /dev/$1 does not exist"; exit 1
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

# handle input
handle_empty_input() {
  local var_name="$1"
  local default_value="$2"
  local prompt_text="$3"
  if [ -z "${!var_name}" ]; then
     echo -e  "$RED\0No $prompt_text found$NC"
    read -p "$prompt_text: [${!var_name:-$default_value}] :" input
    if [ -z "$input" ]; then
      echo -e "defaulting to ${!var_name:-$default_value}"
      eval "$var_name=\$default_value"
    else
      eval "$var_name=\$input"
    fi
  fi
}

inputs()
{
handle_empty_input "HOST"     ""            "Host Name"
handle_empty_input "POOLNAME" "nixos-pool"  "Pool Name"
handle_empty_input "DEVICE"   "nvme0n1"     "main disk device"
handle_empty_input "PART"     "nvme0n1p2"   "nix zfs partition"
handle_empty_input "BOOT"     "nvme0n1p1"   "boot partition"
handle_empty_input "SIZE"     "2GiB"        "boot partition size"
}

format()
{
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
umount /mnt/boot
umount /mnt
zpool destroy $POOLNAME -f
umount $PART
umount $BOOT
umount $DEVICE
}

zfs_create()
{
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

# secrets
install_secrets()
{
  cd $FILE
  cd ./secrets
  while IFS= read -r -p "secret to create : (end with an empty line): " line; do
    [[ $line ]] || break  # break if line is empty
    array+=("$line")
  done
  for i in "${array[@]}"
  do
    ./gen-secret.sh "$HOST" "/persist/secrets" "$i.age"
  done
  cd $FILE
}

# install to system
install_nixos()
{
cd /mnt
nixos-install --impure --flake github:MadMcCrow/nixos-configuration#$HOST
cd $FILE
}

# ask before doing
step()
{
  echo_line "step : $GRE\0$1\0$NC "
  while true; do
        read -p "$1 ? [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
  done
}

# if running in script mode
if [ "$1" = "--dry-run" ]; then
  echo_line "checks"  echo_lined "checks";
  echo_line "clean drive and zfs";
  echo_line "format drive";
  echo_line "create zfs pool";
  echo_line "mount zfs pool";
  echo_line "install nixos";
else
  if step "input settings"; then inputs; fi
  if step "perform checks"; then checks; fi
  if step "clean drives  "; then clean;  fi
  if step "format drives"; then format; fi
  if step "create zfs pool"; then zfs_create; fi
  if step "mount zfs pool"; then zfs_mount;  fi
  if step "install secrets"; then install_secrets;  fi
  if step "install nixos"; then install_nixos;  fi
fi
