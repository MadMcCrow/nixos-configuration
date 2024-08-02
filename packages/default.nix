{ callPackage, lib, ... }:
let
  # list all the packages :
  modules = [
    ./bcrypt
    ./darwin-rebuild
    ./darwin-install
    ./linux-gensh
    ./linux-install
    ./termcolors
  ];

  # generate Attrset of all packages :
in builtins.listToAttrs (map (x: rec {
  value = callPackage x { };
  name = lib.getName value;
}) modules)