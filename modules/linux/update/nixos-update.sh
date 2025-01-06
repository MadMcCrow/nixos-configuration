#!/bin/sh

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

# dependencies :
rebuild=$(which nixos-rebuild)
enroll=$(which nixos-enroll)

# options :
flake="." #@flake@
host="terminus" #@host@
mode="boot"
branch=""
script=0

# Parse Inputs
# TODO : simplify this 
while [ "$#" -gt 0 ]; do
  if [[ $1 =~ $(mkReg "help") ]]; then
    printf "\033[0;35mnixos-update [-s] [-b BRANCH] [-m MODE] [-h HOST] [-f FLAKE]\n\033[0m"
    printf "\t-s, --script\t\trun without input (does not work with password)\n"
    printf "\t-b, --branch\t\tspecify branch to use for update\n"
    printf "\t-m, --mode\t\tone of [boot, switch, test] (from nixos-rebuild), defaults to ($MODE)\n"
    printf "\t-h, --host\t\the host node to build (defaults to $HOST) \n"
    printf "\t-f, --flake\t\the flake to use (defaults to $FLAKE)\n"
    exit 0
  fi
  if [[ $1 =~ $(mkReg "script") ]]; then
    script=1
    continue
  fi
  if [[ $1 =~ $(mkReg "branch") ]]; then
    branch="/$2"; shift 2;
    continue
  fi
  if [[ $1 =~ $(mkReg "mode") ]]; then
    mode=$2; shift 2;
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
spin "@@/bin/nixos-rebuild $MODE --flake $FLAKE$BRANCH#$HOST --refresh"
REBUILD=$?
if [ $REBUILD -ne 0 ]; then
echo "failed to rebuild configuration ($REBUILD)"
exit 1;
fi

# we continue with enrolling disks to TPM
# parse config for encrypted disk to re-enroll with TPM
declare -a TPM_DISKS=$(nix eval -v -L $FLAKE$BRANCH#nixosConfigurations.$HOST.config.boot.initrd.luks.devices --json --extra-experimental-features 'nix-command flakes' --apply 'with builtins; a: concatStringsSep " " (map (x: x.device) (filter (x: any (s: match "tpm2-device.*" s != null) x.crypttabExtraOpts) (attrValues a)))' 2> /dev/null | tr -d '"')
spin "nixos-enroll $TPM_DISKS"

