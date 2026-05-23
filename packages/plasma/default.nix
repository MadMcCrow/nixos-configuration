# packages/plasma/default.nix
# Plasma shell packages
{ mkDrvAttrs, ... }:
mkDrvAttrs
[
./ditto-menu.nix
./plasma-drawer.nix
./vapor-theme.nix
./vinyl-theme.nix
]
