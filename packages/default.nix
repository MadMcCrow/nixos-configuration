{pkgs, ... } :
let
# list all the packages :
 packages = [
  ./bcrypt
 ];
in
# generate Attrset of all packages :
builtins.listToAttrs (map (x: let
p = pkgs.callPackage x {};
in {name = pkgs.lib.getName p; value = p;})
packages)
