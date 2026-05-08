# packages/default.nix
# All packages uniquely provided by nonOS
{ callPackage, ... }@args:
with builtins;
listToAttrs(map (x: let drv = callPackage x args; in {
    inherit (drv) name;
    value = drv;
  })[
    # Plasma shell packages :
    ./plasma/ditto-menu.nix
    ./plasma/plasma-drawer.nix
    ./plasma/vapor-theme.nix
    # zfs encryption
    ./zfs/zfs-fzifdso
    ./zfs/zfs-tzpfms
    # nonOS updater/installer
    ./os
  ])
