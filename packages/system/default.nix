# packages/system/default.nix
# nonOS specific packages
{ mkDrvAttrs, ... }:
mkDrvAttrs
    [
      # nonOS updater/installer
      ./os
      # config validation
      ./config-keys
    ]
