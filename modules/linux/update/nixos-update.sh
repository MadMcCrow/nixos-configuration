#!/bin/sh

# check privileges
if [ "$USER" != "root" ]; then
  printf "Please run nixos-update as root or with sudo\n"; exit 2
fi

# helper function
enroll() {
  if [ $# -eq 0 ]; then return; fi
  return "@systemd@/bin/systemd-cryptenroll $1 --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=@pcrs@"
}

# nixos-rebuild command
rebuild() {
  if [ $# -eq 1 ]; then
    BRANCH="/$1";
  else
    BRANCH="";
  fi
  return "@nixos-rebuild@/bin/nixos-rebuild boot --flake @flake@$BRANCH#@host@ --refresh"
}

spinner() {
  eval $1 &
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
  do
    printf "\b${sp:i++%${#sp}:1}"
  done
  return wait $PID
}


# nixos-rebuild command
printf "updating @host@ from @flake@"
if [ $# -eq 1 ]; then 
spinner $(rebuild $1); 
else 
spinner $(rebuild);
fi
REBUILD=$?

# we continue with enrolling disks to TPM
if [ REBUILD -eq 0 ]; then
    printf "\nenrolling LUKS devices in TPM\n"
    for DISK in @disks@;
    do
    printf "enrolling $DISK to TPM"
    spinner $(enroll $DISK)
    ENROLL=$?
    if [ ENROLL -eq 0 ]; then
      printf "failed ! ($ENROLL)\n"
    else
      printf "\n"
    fi
    done
else
    printf "failed to rebuild configuration ($REBUILD)"
fi
return ($REBUILD + $ENROLL)