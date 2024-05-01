# packages/default.nix
# 	build packages to add to systems
{ pkgs, lib, ... }:
let
 packages = map (x: import x {inherit pkgs;}) 
  [
    ./skm.nix
    ./sshram.nix
  ];
in builtins.listToAttrs (map x : {name = lib.getName x; value = x;}) packages