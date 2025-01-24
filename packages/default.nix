args @{ callPackage, lib, ... }:
let
  # list all the packages :
  modules = [
    ./bcrypt
    ./darwin-install
    ./nbl
    ./termcolors
  ];
in
# generate Attrset of all packages :
builtins.listToAttrs (
  map (x: rec {
    value = callPackage x args;
    name = lib.getName value;
  }) modules
)
