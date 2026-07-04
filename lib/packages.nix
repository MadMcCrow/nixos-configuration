packages = map
( p :
let
  pkg = pkgs.callPackage p inputs;
  dirname = lib.path.removePrefix path (builtins.dirOf p);
in
lib.setAttrByPath ((lib.path.subpath.components dirname) ++ [(lib.getName pkg)]) pkg )
((import-tree.withLib lib).leafs ./packages);
