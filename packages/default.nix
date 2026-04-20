# packages/default.nix
# All packages uniquely provided by nonOS
{
  system,
  nixpkgs,
  self,
  ...
}@args:
with builtins;
let
    pkgs = nixpkgs.legacyPackages.${system};

    mkPkgAttr = drv : { name = drv.name; value = drv; };
    mkPyPackage = attr : import (self + /lib/python/mkPythonPackage.nix) (args // { inherit pkgs;}) attr;

    mkPyPackages = map (x: mkPkgAttr (mkPyPackage x));
    mkNixPackages = map (x: mkPkgAttr (pkgs.callPackage x args));
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
        {name = "os-update"; rootdir = ./os-update; venv = "os-update";}
      ]
))
