# packages.nix
# helper to get the list of packages in flake
inputs@{
  pkgs,
  lib,
  import-tree,
  ...
}:
let
  collect = p: import-tree (i: i.map (x: pkgs.callPackage x inputs)) (i: i.leafs p);

  # collect all packages
  packages = lib.flatten (
    map collect [
      ./plasma
      ./misc
      ./zfs
    ]
  );
in
builtins.listToAttrs (
  map (pkg: {
    name = lib.getName pkg;
    value = pkg;
  }) packages
)
