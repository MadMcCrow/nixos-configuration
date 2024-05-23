{ pkgs, ... }:
let
  # list all the packages :
  packages = [ ./bcrypt ];
  # generate Attrset of all packages :
in builtins.listToAttrs (map (x:
  let p = pkgs.callPackage x { };
  in {
    name = pkgs.lib.getName p;
    value = p;
  }) packages)
