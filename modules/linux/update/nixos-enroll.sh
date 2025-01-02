# A simple script to enroll all the drives in your config with tpm and/or fido
#!/bin/sh
set -e # stop at errors

# vars that will get replaced by nix or arguments :
INTERACTIVE=0
ENROLL_FIDO=1
ENROLL_TPM=1
DISKS=()
PCRS=(0 1 2 7 9)  #@pcrs@

# get path to dependencies 
fido2=$(which fido2-token)
# cryptenroll=$(which systemd-cryptenroll) #@systemd@/bin/systemd-cryptenroll

# Parse Inputs
# TODO : simplify this 
while [ "$#" -gt 0 ]; do
  if [[ $1  == "--script" ]]; then
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
  echo "add disk $1"
  DISKS+=$1
  shift
done

# parse config for encrypted disk to re-enroll
FLAKE="." #@flake@
HOST="terminus" #@host@ # use uname -n
BRANCH=""

#declare -a initrd_disk=$(nix eval -v -L $FLAKE$BRANCH#nixosConfigurations.$HOST.config.boot.initrd.luks.devices --json --extra-experimental-features 'nix-command flakes' --apply 'with builtins; a: concatStringsSep " " (map (x: x.device) (filter (x: any (s: match "tpm2-device.*" s != null) x.crypttabExtraOpts) (attrValues a)))' 2> /dev/null | tr -d '"')
#DISKS+=( "${DISKS[@]}" "${initrd_disk[@]}")
DISKS=("/dev/nvme0n1p1")

for disk in $DISKS; do
    #command="$cryptenroll $disk"
    command="echo 'ded tpm'"
    # check if already enrolled
    status=$(eval "$command")
        echo "here !"
    use_fido=$([[ $status =~ *fido* ]]);
    echo "here !"
    use_tpm=$([[ $status =~ *tpm* ]]);

    grep=$( eval "$fido2 -L" 2> /dev/null | grep "vendor")
    fido_plugged=[[ ! -n "${grep// /}" ]];

    if [[ $ENROLL_FIDO -eq 0 ]]; then 
        echo "enrolling $disk with FIDO2 device"
        if [ use_fido ]; then 
        >&2 echo "warning : already registered with FIDO, will wipe slot !"
        fi
        # TODO : add option for enabling presence !
        echo "$command --wipe-slot=fido2 --fido2-device=auto --fido-with-user-presence=false"
        use_fido=$?
        echo "use fido = $use_fido"
    fi

    if [[ $ENROLL_TPM ]]; then
        echo "enrolling $disk with TPM2 device"
        command_tpm="$command --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=$PCRS"
        if [ use_tpm ]; then 
        >&2 echo "warning : already enrolled with TPM2, will wipe slot !"
        fi
        if [ use_fido ]; then 
            echo "$command_tpm --unlock-fido2-device=auto"
        else
            if [ ! INTERACTIVE ]; then 
                >&2 echo "error : need user interaction to rewrite password"
            else
                echo $command_tpm
            fi
        fi
        use_tpm=$?
        echo "use tpm = $use_tpm"
    fi
done
exit 0