# packages.nix
# helper to get the list of packages in flake
{
  lib,
  import-tree,
  self,
  ...
} :
builtins.listToAttrs
  (map (p: let pkg = pkgs.callPackage p (inputs // {inherit nonlib;}) ;
    in { name = lib.getName pkg; value = pkg;})
  ((import-tree.withLib lib).leafs (self + ./packages)));
