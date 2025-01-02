#!/bin/sh
set -e # stop at errors

# vars that will get replaced by nix or arguments :
FLAKE="." #@flake@
HOST="terminus" #@host@

# parse arguments :
MODE="boot"
BRANCH=""
INTERACTIVE=0

# generate regex for option name
function mkReg {
  echo "(-$(printf %.1s "$1"))|(--$1)"
}
# replace running function output by a spinning bar
function spin {
  eval $1 2>&1 &
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
  do
    printf "\b${sp:i++%${#sp}:1}"
    sleep 0.1
  done
  return $(wait $PID)
};


# Parse Inputs
# TODO : simplify this 
while [ "$#" -gt 0 ]; do
  if [[ $1 =~ $(mkReg "script") ]]; then
    INTERACTIVE=1
    continue
  fi
  if [[ $1 =~ $(mkReg "branch") ]]; then
    BRANCH="/$2"; shift 2;
    continue
  fi
  if [[ $1 =~ $(mkReg "mode") ]]; then
    MODE=$2; shift 2;
    continue
  fi
  if [[ $1 =~ $(mkReg "host") ]]; then
    HOST="/$2"; shift 2;
    continue
  fi
   if [[ $1 =~ $(mkReg "flake") ]]; then
    FLAKE="/$2"; shift 2;
    continue
  fi
  echo "unrecognized option $1"
  exit 1
done

# parse config for encrypted disk to re-enroll with TPM
declare -a TPM_DISKS=$(nix eval -v -L $FLAKE$BRANCH#nixosConfigurations.$HOST.config.boot.initrd.luks.devices --json --extra-experimental-features 'nix-command flakes' --apply 'with builtins; a: concatStringsSep " " (map (x: x.device) (filter (x: any (s: match "tpm2-device.*" s != null) x.crypttabExtraOpts) (attrValues a)))' 2> /dev/null | tr -d '"')

# detect if disks can be unlock with 
if [[ $INTERACTIVE -eq 0 ]]; then 
for DISK in $TPM_DISKS; do
GREP="" #$(@systemd@/bin/systemd-cryptenroll $DISK | grep "fido");
if [[ ! -n "${GREP// /}" ]]; then
echo "disk $DISK not registered with fido device, cannot enroll tpm without user input !"
fi

done
fi
exit 0

# ROOT IS NECESSARY PAST THIS POINT
# check privileges
if [ "$USER" != "root" ]; then
  printf "Please run nixos-update as root or with sudo\n"; exit 2
fi




# do actual update :
# hide wall of text and let a spinner do the talking
echo "updating $HOST from $FLAKE$BRANCH"
spin "@nixos-rebuild@/bin/nixos-rebuild $MODE --flake $FLAKE$BRANCH#$HOST --refresh"
REBUILD=$?
if [ $REBUILD -ne 0 ]; then
echo "failed to rebuild configuration ($REBUILD)"
exit 1;
fi

# we continue with enrolling disks to TPM
for DISK in "${TPM_DISKS[@]}"; do
printf "enrolling $DISK to TPM"
spin "@systemd@/bin/systemd-cryptenroll $DISK --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=@pcrs@ --unlock-fido2
ENROLL=$?
if [ $ENROLL -ne 0 ]; then
printf "failed ! ($ENROLL)\n"
    else
      printf "\n"
    fi
    done
else
   