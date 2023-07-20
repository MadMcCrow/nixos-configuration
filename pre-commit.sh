#!/usr/bin/env sh
# Custom Pre-commit hook for nixos-configuration :

# Colors for output
GRE='\033[0;32m'
BLU='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# count characters
ccount() {
    nc=$(echo $1  | sed 's/\\033\[[0-9;]\{1,\}m//g' )
    nn=$(echo $nc | sed 's/\\0//g')
    echo ${#nn}
}

# echo on a dotted line
echo_line() {
  local t=" $1 "
  local l=50
  local c=$(ccount "$1")
  local p=true
  while [ $c -lt $l ]; do
    if $p; then
      t="${t}-"
      p=false
    else
      t="-${t}"
      p=true
    fi
    c=$(( c + 1 ))
  done
  echo -e "$t"
}


# get changed files
CHANGED_FILES="$(git diff --cached --name-only --diff-filter=ACM -- '*.nix')";

# Format with nixfmt
echo_line "Format: $BLU\0nixfmt$NC"
if [ -n "$CHANGED_FILES" ]; then
  for FILE in $CHANGED_FILES
  do
    nix-shell -p nixfmt --run "nixfmt  <$FILE" 1> /dev/null;
    RES=$?
    if [ $RES -ne 0 ]; then
    echo -e "Error: $RED\0$FILE\0$NC is not formatted, run $BLU'nixfmt $FILE'$NC"
    echo_line "Format complete: $RED\0 Error !$NC"
    exit $RES
    fi
  done
fi
echo_line "format complete: $GRE\0 Success !$NC"

# Validate configurations :
## get configs :
echo_line "Building: $BLU\0 nix build nixosConfigurations $NC"
CONFIGS=$(nix-shell -p jq --run "nix flake show --json | jq  -c '.nixosConfigurations | keys' | tr -d '[\"]' | tr ',' '\n'")
for CONF in $CONFIGS
do
  echo -n "dry building $CONF :"
  #nixos-rebuild dry-activate --flake .#$CONF --impure 1> /dev/null
  nix build .#nixosConfigurations.$CONF.config.system.build.toplevel --no-link  --cores 0  --quiet --quiet --impure 1> /dev/null
  RES=$?
  if [ $RES -ne 0 ]; then
    echo -e "$RED\0Error:$NC Cannot build configuration $BLU\0$CONF\0$NC : edit and test with $BLU'nixos-rebuild dry-activate --flake .#$CONF --impure --show-trace'$NC"
    echo_line "check complete: $RED\0 Error !$NC"
    exit $RES
  else
  echo -e "build complete :   $BLU\0$CONF\0$NC : $GRE\0Success! $NC"
  fi
done
echo_line "check complete: $GRE\0 Success !$NC"
