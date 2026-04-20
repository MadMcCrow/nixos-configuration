# packages/default.nix
# All packages uniquely provided by nonOS
{
  system,
  nixpkgs,
  ...
}@args:
with builtins;
let
    pkgs = nixpkgs.legacyPackages.${system};
    mkPyPackage = name : import self + /lib/python/mkPythonPackage.nix (args // { inherit pkgs;}) name;
    mkPyPackages = l: map (x: { name = x; value =  mkPyPackage x; }) l;
    mkNixPackages = l: map (x: { name = x; value =  pkgs.callPackage x args; }) l;
in
# merge list into an attrset :
listToAttrs (
# Plasma shell packages :
(mkNixPackages [
  ./plasma/ditto-menu.nix
  ./plasma/plasma-drawer.nix
  ./plasma/vapor-theme.nix
])
# ZFS encryption packages :
++ (mkNixPackages [
  ./zfs/zfs-fzifdso
  ./zfs/zfs-tzpfms
])
# Python packages :
++ (mkPyPackages [
        "os-update"
      ]
));
