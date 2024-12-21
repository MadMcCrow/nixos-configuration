#!/bin/sh
set -e # stop at errors

# parse arguments :
MODE="boot"
BRANCH=""
BRANCH_REGEX="-{1,2}b(ranch)*"
MODE_REGEX="-{1,2}m(ode)*"
while [ "$#" -gt 0 ]; do
  if [[ $1 =~ $BRANCH_REGEX ]]; then
    BRANCH="/$2"; shift 2;
    continue
  fi
  if [[ $1 =~ $MODE_REGEX ]]; then
    MODE=$2; shift 2;
    continue
  fi
  shift
done


# wrapper function :
# hide wall of text and let a spinner do the talking
spinner() {
  eval "$1" &
  PID=$!
  echo "$1 started with PID $PID"
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
  do
    printf "\b${sp:i++%${#sp}:1}"
    sleep 0.1
  done
  return $(wait $PID)
}

# check privileges
if [ "$USER" != "root" ]; then
  printf "Please run nixos-update as root or with sudo\n"; exit 2
fi


# nixos-rebuild command
printf "updating @host@ from @flake@$BRANCH"
spinner "@nixos-rebuild@/bin/nixos-rebuild $MODE --flake @flake@$BRANCH#@host@ --refresh"
REBUILD=$?
printf "\n"

# we continue with enrolling disks to TPM
declare -a DISKS=(@disks@)
if [ $REBUILD -eq 0 ]; then
    printf "\nenrolling LUKS devices in TPM\n"
    for DISK in "${DISKS[@]}";
    do
    printf "enrolling $DISK to TPM"
    eval "@systemd@/bin/systemd-cryptenroll $DISK --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=@pcrs@"
    ENROLL=$?
    if [ $ENROLL -ne 0 ]; then
      printf "failed ! ($ENROLL)\n"
    else
      printf "\n"
    fi
    done
else
    printf "failed to rebuild configuration ($REBUILD)"
fi
exit 0