# packages/system/default.nix
# nonOS specific packages
{ mkDrvAttrs, ... }:
mkDrvAttrs
    [
      # nonOS updater/installer
      ./os.nix
      # build shell script
      ./os-build.nix
      # config validation
      ./config-keys.nix
    ]
