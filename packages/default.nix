# packages/default.nix
# All packages uniquely provided by nonOS
{ system, nixpkgs, self, ... }@args:
with builtins;
let
  pkgs = nixpkgs.legacyPackages.${system};

  mkPkgAttr = drv: {
    inherit (drv) name;
    value = drv;
  };
  mkPyPackage = attr:
    import (self + /lib/python/mkPythonPackage.nix) (args // inputs // { inherit pkgs; })
    attr;

  mkPyPackages = map (attr: {
    inherit (attr) name;
    value = mkPyPackage attr;
  });
  mkNixPackages = map (x: mkPkgAttr (pkgs.callPackage x args));
  # merge list into an attrset :
in listToAttrs (
  # Plasma shell packages :
  (mkNixPackages [
    ./plasma/ditto-menu.nix
    ./plasma/plasma-drawer.nix
    ./plasma/vapor-theme.nix
  ])
  # ZFS encryption packages :
  ++ (mkNixPackages [ ./zfs/zfs-fzifdso ./zfs/zfs-tzpfms ])
  # Python packages :
  ++ (mkPyPackages [{
    name = "os-update";
    rootdir = ./os-update;
    venv = "os-update";
  }]))
