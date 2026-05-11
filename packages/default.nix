# packages/default.nix
# All packages uniquely provided by nonOS
{ callPackage, lib, ... }@args:
with builtins;
listToAttrs (
  map
    (
      x:
      let
        drv = callPackage x args;
      in
      {
        name = lib.getName drv;
        value = drv;
      }
    )
    [
      # Plasma shell packages :
      ./plasma/ditto-menu.nix
      ./plasma/plasma-drawer.nix
      ./plasma/vapor-theme.nix
      # zfs encryption
      ./zfs/zfs-fzifdso
      ./zfs/zfs-tzpfms
      # nonOS updater/installer
      ./os
      # config validation
      ./config-keys
    ]
)
