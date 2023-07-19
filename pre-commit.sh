#!/usr/bin/env sh
# Custom Pre-commit hook for nixos-configuration :
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

error() {
echo -e "ERROR:$RED$1$NC"
}
border() {
echo -e "$CYAN$1$NC"
}

# get changed files
CHANGED_FILES="$(git diff --cached --name-only --diff-filter=ACM -- '*.nix')";

# Format with nixfmt
border "----- Format: nixfmt  -----"
if [ -n "$CHANGED_FILES" ]; then
  for FILE in $CHANGED_FILES
  do
    nix-shell -p nixfmt --run "nixfmt  <$FILE" 1> /dev/null;
    RES=$?
    if [ $RES -ne 0 ]; then
    echo "Error: $FILE is not formatted, run 'nixfmt $FILE'"
    exit $RES
    fi
  done
fi
border "-----   done nixfmt   -----"

# Validate configurations :
## get configs :
border "----- testing configs -----"
CONFIGS=$(nix-shell -p jq --run "nix flake show --json | jq  -c '.nixosConfigurations | keys' | tr -d '[\"]' | tr ',' '\n'")
for CONF in $CONFIGS
do
  echo -n "dry building $CONF :"
  #nixos-rebuild dry-activate --flake .#$CONF --impure 1> /dev/null
  nix build .#nixosConfigurations.$CONF.config.system.build.toplevel --no-link  --cores 0  --quiet --quiet --impure 1> /dev/null
  RES=$?
  if [ $RES -ne 0 ]; then
    echo -e "Cannot build configuration $CONF : edit and test with 'nixos-rebuild dry-activate --flake .#$CONF --impure --show-trace'"
    exit $RES
  fi
done
border "-----  done testing   -----"
