#!/bin/bash

# copy scriptdir
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# replace running function output by a spinning bar
function spin {
  eval "$1" 2>&1 &
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
  do
    printf "\b%s" "${sp:i++%${#sp}:1}"
    sleep 0.1
  done
  return "$(wait $PID)"
};

# dependencies :
rebuild=$(which nixos-rebuild)
enroll=$(which luks-enroll)

# options :
flake="." #@flake@
host=$(uname -n) #@host@
mode="boot"
branch=""
interactive=0
dryrun=1

# Parse Inputs
# TODO : simplify this 
while [ "$#" -gt 0 ]; do
  if [[ $1 =~ (-h)|(--help) ]]; then
    printf "\033[0;35mnixos-update [-s] [-b BRANCH] [-m MODE] [-h HOST] [-f FLAKE]\n\033[0m"
    printf "\t-h, --help\t\tshow this help info\n"
    printf "\t-s, --script\t\trun without input (does not work with password)\n"
    printf "\t-b, --branch\t\tspecify branch to use for update (defaults to %s)\n" "$branch"
    printf "\t-m, --mode\t\tone of [boot, switch, test] (from nixos-rebuild), defaults to (%s)\n" "$mode"
    printf "\t-t, --host\t\tthe host node to build (defaults to %s) \n" "$host"
    printf "\t-f, --flake\t\tthe flake to use (defaults to %s)\n" "$flake"
    printf "\t-d, --dry-run\t\tdo not perform actions\n"
    exit 0
  fi
  if [[ $1 =~ (-s)|(--script) ]]; then
    interactive=1; shift;
    continue
  fi
  if [[ $1 =~ (-b)|(--branch) ]]; then
    branch="/$2"; shift 2;
    continue
  fi
  if [[ $1 =~ (-m)|(--mode) ]]; then
    mode=$2; shift 2;
    continue
  fi
  if [[ $1 =~ (-H)|(--host) ]]; then
    host="$2"; shift 2;
    continue
  fi
  if [[ $1 =~ (-f)|(--flake) ]]; then
    flake="$2"; shift 2;
    continue
  fi
  if [[ $1 =~ (-d)|(--dry-run) ]]; then
    dryrun=0 ; shift;
    continue
  fi
  echo "unrecognized option $1"
  exit 1
done

# parse config for encrypted disk to re-enroll with TPM
nixfeatures=(--extra-experimental-features 'nix-command flakes')
nixconfig=$(nix eval -v -L "$flake$branch#nixosConfigurations.$host.config.boot.initrd.luks.devices" "${nixfeatures[@]}" 2>/dev/null)
tpm_disks=$(nix eval  --file "$script_dir/nixparsedisks.nix" --apply "f: f $nixconfig" | tr -d '"' | tr ' ' '\n' )
mapfile -t tpm_disks <<< "$tpm_disks"


# check we can re-enroll disks after update (to prevent lock up)
if [[ ${#tpm_disks[@]} -ne 0 ]]; then
  result=$($enroll -s -t -d "${tpm_disks[@]}" 2>/dev/null)
  if [[ $result -ne 0 ]]; then 
    >&2 printf "\033[0;33merror:\033[0m failed to update, check for re-enroll failed\n"
    exit 1
  fi
fi

# write down commands
rebuild_args="$rebuild $mode --flake $flake$branch#$host --refresh"

# ROOT IS NECESSARY PAST THIS POINT
if [ $dryrun -eq 0 ]; then
  rebuild_args+=" --dry-run";
else
  if [ "$USER" != "root" ]; then
    >&2 printf "\033[0;33merror:\033[0m please run nixos-update as root or with sudo\n"
    exit 2
  fi
fi

# do actual update :
# hide wall of text and let a spinner do the talking
printf "updating \033[0;32m%s\033[0m from %s\n" "$host" "$flake$branch"
spin "$rebuild_args"
result=$?
if [ $result -ne 0 ]; then
  >&2 printf "\033[0;33merror:\033[0m failed to rebuild configuration (exit code = %s)\n" "$result"
  exit 1;
fi


if [ $dryrun -ne 0 ]; then
  if [ $interactive -ne 0 ]; then 
    spin "$enroll -s -t ${tpm_disks[*]}"
  else
    spin "$enroll -t ${tpm_disks[*]}"
  fi
  result=$?
  if [ $result -ne 0 ]; then
    >&2 printf "\033[0;33mcritical error !\033[0m failed to update, re-enroll failed !\n"
    exit 3 # very important error ! should not be ignored (your device may lock itself)
  fi
fi

# all is OK !
exit 0
