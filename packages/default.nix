# packages/default.nix
# All packages uniquely provided by nonOS
{ pkgs, system, self, ... }@args:
with builtins;
let

  mkPkgAttr = drv: {
    inherit (drv) name;
    value = drv;
  };
  pylib =  import (self + /lib/python.nix) (args // { inherit pkgs; });


  mkPyPackages = map (attr: {
    inherit (attr) name;
    value = pylib.mkPythonPackage attr;
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
  }
  {
    name = "os-install";
    rootdir = ./os-install;
    venv = "os-install";
  }])
