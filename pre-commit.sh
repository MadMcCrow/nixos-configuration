#!/usr/bin/env sh
# Custom Pre-commit hook for nixos-configuration :

CHANGED_FILES="$(git diff --cached --name-only --diff-filter=ACM -- '*.nix')";

# Format with nixfmt
echo "----- Format: nixfmt  -----"
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
echo "-----   done nixfmt   -----"

# Validate configurations :
## get configs :
echo "----- testing configs -----"
CONFIGS=$(nix-shell -p jq --run "nix flake show --json | jq  -c '.nixosConfigurations | keys' | tr -d '[\"]' | tr ',' '\n'")
if ![ ${#CHANGED_FILES[@]} -eq 0 ]; then
  for CONF in $CONFIGS
  do
    echo "dry building $CONF :"
    nixos-rebuild dry-activate --flake .#$CONF --impure 1> /dev/null
    RES=$?
    if [ $RES -ne 0 ]; then
      echo "Cannot build configuration $CONF : edit and test with 'nixos-rebuild dry-activate --flake .#$CONF --impure'"
      exit $RES
    fi
  done
fi
echo "-----  done testing   -----"
