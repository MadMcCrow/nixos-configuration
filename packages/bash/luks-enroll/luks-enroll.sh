#!/usr/bin/env bash
# A simple script to enroll all the drives in your config with tpm and/or fido

# vars that will get replaced by nix or arguments :
interactive=0
enroll_fido=1
enroll_tpm=1
devices=()
pcrs=(0 1 2 7 9)
dry=1

# Parse Inputs (maybe replace with a script to parse inputs ?)
while [ "$#" -gt 0 ]; do
  if [[ $1 =~ (-h)|(--help) ]]; then
    printf "\033[0;35mluks-enroll DEVICES [-s] [-f] [-t] [-p NUM]\033[0m\n"
    printf "\tDEVICES\t\t\tspace separated list of devices to enroll \n\t\t\t\t(ex: sda1 or /dev/disks/by-uuid/xxxxxx-xxxxxx)\n"
    printf "\t-s, --script     \trun without input (does not work with password)\n"
    printf "\t-f, --enroll-fido\tenroll devices with fido2 device\n"
    printf "\t-t, --enroll-tpm \tenroll devices with TPM2 device\n"
    printf "\t-p, --pcr NUM    \tadd PCRS (defaults to 0 1 2 7 )\n"
    printf "\t-d, --dry-run \t\t run without performing enroll (to get return code)\n"
    exit 0
  fi
  if [[ $1 =~ (-s)|(--script) ]]; then
    interactive=1; shift;
    continue
  fi
  if [[ $1 =~ (-f)|(--enroll-fido) ]]; then
    enroll_fido=0; shift;
    continue
  fi
  if [[ $1 =~ (-t)|(--enroll-tpm) ]]; then
    enroll_tpm=0; shift;
    continue
  fi
  if [[ $1 =~ (-p)|(--pcr) ]]; then
    pcrs+=("$2"); shift 2;
    continue
  fi
   if [[ $1 =~ (-d)|(--dry-run) ]]; then
    dry=0; shift;
    continue
  fi
  echo "add disk $1"
  devices+=("$1")
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
fido_count=$(echo "$fido_devices" | wc -l)
if [[ enroll_fido -eq 0 ]]; then
    if [[ -z $fido2 ]]; then
        >&2 printf "\033[0;31merror:\033[0m missing libfido, cannot use fido security devices\n"
        exit 1
    fi
    if [[ $fido_count -lt 1 ]]; then
        >&2 printf "\033[0;31merror:\033[0m no FIDO2 device plugged, aborting\n"
        exit 1
    fi
fi

for disk in "${devices[@]}"; do
  # fixup devices without "/dev/"
  if [[ $disk == sd* || $disk == nvme* ]]; then
    disk="/dev/$disk"
  fi
  
  command="$cryptenroll $disk"
  # check if already enrolled
  status=$(eval "$command")
  # shellcheck disable=SC2319 # it is actually the desired behaviour !
  use_fido=$([[ $status =~ .*fido.* ]]; echo $?)
  use_tpm=$([[ $status =~ .*tpm.* ]]; echo $?)

  # FIDO2
  if [[ $enroll_fido -eq 0 ]]; then
    fido_command="$command --wipe-slot=fido2 --fido2-device=auto --fido-with-user-presence=false"
    if [[ $dry -eq 0 ]]; then
      printf " would run: \`\033[0;33m%s\033[0m\`\n" "$fido_command"
    else
      printf "enrolling \033[0;36m%s\033[0m with FIDO2 device\n" "$disk"
      if [[ $use_fido -eq 0 ]]; then 
          >&2 printf "\033[0;33mwarning:\033[0m already registered with FIDO, will wipe slot !\n"
      fi
      # TODO : add option for enabling presence !
      eval "$fido_command"
      use_fido=$?
    fi
    # exit on failure !
    if [[ $use_fido -ne 0 ]]; then
      if [[ $dry -ne 0 ]]; then
        >&2 printf "\033[0;31merror:\033[0m failed to enroll %s to FIDO2 device\n" "$disk"
      fi
      exit "$use_fido"
    fi
  fi
  
  # TPM2
  if [[ $enroll_tpm -eq 0 ]]; then
    # build command
    for pcr in "${pcrs[@]}"; do
        tpm2pcrs="$tpm2pcrs+$pcr"
    done
    tpm_command="$command --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=$tpm2pcrs"
    # dry 
    if [[ $dry -eq 0 ]]; then
      printf " would run: \`\033[0;33m%s\033[0m\`\n" "$tpm_command"
      if [[ $interactive -ne 0 ]]; then 
        if [[ $use_fido -ne 0 ]] || [[ $fido_count -lt 1 ]]; then
          >&2 printf "\033[0;31merror:\033[0m would not re-enroll, missing fido device\n"
          exit 1
        fi
      fi
    else
      printf "enrolling \033[0;36m%s\033[0m with TPM2 device" "$disk"
      if [[ $use_tpm -eq 0 ]]; then 
        >&2 printf "\033[0;33mwarning:\033[0m already enrolled with TPM2, will wipe slot !\n"
      fi
      # try unlock with fido !
      if [[ $use_fido -eq 0 ]]  && [[ $fido_count -gt 0 ]]; then 
        eval "$tpm_command --unlock-fido2-device=auto"
      else
        if [[ $interactive -ne 0 ]]; then 
          >&2 printf "\033[0;31merror:\033[0m need user interaction to rewrite password\n"
          exit 1
        fi
        eval "$tpm_command"
        use_tpm=$?
      fi
    fi
    # exit on failure !
    if [[ $use_tpm -ne 0 ]]; then
      if [[ $dry -ne 0 ]]; then
        >&2 printf "\033[0;31merror:\033[0m failed to enroll %s to FIDO2 device\n" "$disk"
      fi
      exit "$use_tpm"
    fi
  fi
done
exit 0