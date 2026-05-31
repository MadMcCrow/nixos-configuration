# packages/system/default.nix
# nonOS specific packages
{ mkDrvAttrs, ... }:
mkDrvAttrs
    [
      # nonOS updater/installer
      ./os.nix
      # config validation
      ./config-keys.nix
    ]
