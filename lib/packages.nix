# packages.nix
# helper to get the list of packages in flake
inputs@{
  pkgs,
  lib,
  import-tree,
  self,
  ...
} :
let
# collect all packages
packages = import-tree
      (i: i.map (x : pkgs.callPackage x (inputs)))
      (i: i.withLib lib)
      (i: i.leafs  (self + "/packages"));

# mapping function to import and wrap packages
in
builtins.listToAttrs
  (map (pkg :
    {
      name = lib.getName pkg;
      value = pkg;
    }) packages)
