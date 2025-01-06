# A simple script to enroll all the drives in your config with tpm and/or fido
#!/bin/sh

# vars that will get replaced by nix or arguments :
INTERACTIVE=0
ENROLL_FIDO=1
ENROLL_TPM=1
DISKS=()
PCRS=(0 1 2 7 9)

# Parse Inputs
# TODO : simplify this 
while [ "$#" -gt 0 ]; do
  if [[ $1 =~ (-h)|(--help) ]]; then
    printf "\033[0;35mnixos-enroll DISKS [-s] [-f] [-t] [-p NUM]\033[0m\n"
    printf "\tDISKS\t\t\tlist of disks to enroll\n"
    printf "\t-s, --script     \trun without input (does not work with password)\n"
    printf "\t-f, --enroll-fido\tenroll disks with fido2 device\n"
    printf "\t-t, --enroll-tpm \tenroll disks with TPM2 device\n"
    printf "\t-p, --pcr NUM    \tadd PCRS (already does 0 1 2 7 )\n"
    printf "\t-T, --test \t\t run without performing enroll (to get return code)\n"
    exit 0
  fi
  if [[ $1 =~ (-s)|(--script) ]]; then
    INTERACTIVE=1; shift;
    continue
  fi
  if [[ $1 =~ (-f)|(--enroll-fido) ]]; then
    ENROLL_FIDO=0; shift;
    continue
  fi
  if [[ $1 =~ (-t)|(--enroll-tpm) ]]; then
    ENROLL_TPM=0; shift;
    continue
  fi
  if [[ $1 =~ (-p)|(--pcr) ]]; then
    PCRS+=$2; shift 2;
    continue
  fi
  echo "add disk $1"
  DISKS+=$1
  shift
done

# Dependencies 
fido2=$(which fido2-token)
cryptenroll=$(which systemd-cryptenroll)

if [[ -z $cryptenroll ]]; then
    >&2 printf "\033[0;31merror:\033[0m systemd not installed on this system !\n"
    exit 1
fi

# detect plugged-in fido devices :
fido_devices=$(eval "$fido2 -L" 2> /dev/null)
fido_count=$(echo $fido_devices | wc -l)
if [[ ENROLL_FIDO -eq 0 ]]; then
    if [[ -z $fido2 ]]; then
        >&2 printf "\033[0;31merror:\033[0m missing libfido, cannot use fido security devices\n"
        exit 1
    fi
    if [ $fido_count -lt 1  ]; then
        >&2 printf "\033[0;31merror:\033[0m no FIDO2 device plugged, aborting\n"
        exit 1
    fi
fi

for disk in $DISKS; do
    command="$cryptenroll $disk"
    # check if already enrolled
    status=$(eval "$command")
    use_fido=$([[ $status =~ .*fido.* ]]);
    use_tpm=$([[ $status =~ .*tpm.* ]]);

    if [[ $ENROLL_FIDO -eq 0 ]]; then
        printf "enrolling \033[0;36m$disk\033[0m with FIDO2 device\n"
        if [ -z use_fido ]; then 
            >&2 printf "\033[0;33mwarning:\033[0m already registered with FIDO, will wipe slot !\n"
        fi
        # TODO : add option for enabling presence !
        eval "$command --wipe-slot=fido2 --fido2-device=auto --fido-with-user-presence=false"
        use_fido=$?
        # exit on failure !
        if [[ use_fido -ne 0 ]]; then
            >&2 printf "\033[0;31merror:\033[0m failed to enroll $disk to FIDO2 device\n"
        exit $use_fido
        fi
    fi

    if [ $ENROLL_TPM -eq 0 ]; then
        echo "enrolling \033[0;36m$disk\033[0m with TPM2 device"
        for pcr in "${PCRS[@]}"; do
            tpm2pcrs+=("+$pcr")
        done
        command_tpm="$command --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=$tpm2pcrs"
        if [ use_tpm ]; then 
        >&2 printf "\033[0;33mwarning:\033[0m already enrolled with TPM2, will wipe slot !\n"
        fi
        if [ use_fido ]  && [ $fido_count -gt 0 ]; then 
            eval "$command_tpm --unlock-fido2-device=auto"
        else
            if [ ! INTERACTIVE ]; then 
            >&2 printf "\033[0;31merror:\033[0m need user interaction to rewrite password\n"
            exit 1
            fi
            eval $command_tpm
        fi
        use_tpm=$?
    fi
done
exit 0