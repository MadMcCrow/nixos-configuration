#!/usr/bin/env sh
# Custom Pre-commit hook for nixos-configuration :

# if we modified the nix configuration :
CHANGED_FILES="$(git diff --cached --name-only --diff-filter=ACM -- '*.nix')";
if [ -n "$CHANGED_FILES" ]; then
  # check nixfmt :
  exec ./nixfmt.sh "$CHANGED_FILES"
  # check build
  CONFIGS=$(nix-shell -p jq --run "nix flake show --json | jq  -c '.nixosConfigurations | keys' | tr -d '[\"]' | tr ',' '\n'")
  for CONF in $CONFIGS
  do
    exec ./build-config.sh "$CONF"
  done
fi
