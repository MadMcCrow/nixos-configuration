#!/usr/bin/env sh
# build-config.sh 
#   A simple script to dry activate your nixos config to test for errors

# just pass the nixos Host you want to dry build to the script
HOST=$1

printf "building nixos configuration for \033[0;34m$HOST\033[0m...\n"
# another way would be  #nixos-rebuild dry-activate --flake .#$CONF --impure 1> /dev/null but that's linux only
nix build .#nixosConfigurations.$HOST.config.system.build.toplevel --no-link --dry-run --cores 0 --quiet --quiet --no-eval-cache  > /dev/null 2>&1
RES=$?
if [ $RES -ne 0 ]; then
    printf "\033[0;31m\0Error:\033[0m Cannot build configuration \033[0;34m$HOST\033[0m\n"
    printf "Edit and test with \033[1;34m'nix build .#nixosConfigurations.$HOST.config.system.build.toplevel --no-link --dry-run --cores 0 --quiet --quiet --no-eval-cache'\033[0m"
    exit $RES
else
  printf "build complete: \033[0;34m$CONF\033[0m \033[0;32mSuccess!\033[0m"
fi