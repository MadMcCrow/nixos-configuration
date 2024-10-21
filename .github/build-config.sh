#!/usr/bin/env sh
# build-config.sh 
#   A simple script to dry activate your nixos config to test for errors

# just pass the nixos Host you want to dry build to the script
HOST=$1
CMD="nix build .#nixosConfigurations.$HOST.config.system.build.toplevel --dry-run --cores 0 --quiet --no-eval-cache --extra-experimental-features nix-command --extra-experimental-features flakes"

printf "building nixos configuration for \033[0;34m$HOST\033[0m...\n"
$CMD > /dev/null
RES=$?
if [ $RES -ne 0 ]; then
    printf "\033[0;31m\0Error:\033[0m Cannot build configuration \033[0;34m$HOST\033[0m\n"
    printf "Edit and test with \033[1;34m'$CMD'\033[0m"
    exit $RES
else
  printf "build complete: \033[0;34m$CONF\033[0m \033[0;32mSuccess!\033[0m"
fi