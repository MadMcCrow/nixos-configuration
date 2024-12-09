{ callPackage, lib, ... }:
let
  # list all the packages :
  modules = [
    ./bcrypt
    ./darwin-rebuild
    ./darwin-install
    ./termcolors
  ];

in
# generate Attrset of all packages :
builtins.listToAttrs (
  map (x: rec {
    value = callPackage x { };
    name = lib.getName value;
  }) modules
)
