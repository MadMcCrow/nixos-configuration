# packages/default.nix
# 	build packages to add to systems
{ pkgs, lib, ... }:
{
  packages = map (x: import x {inherit pkgs;}) 
  [
    ./skm.nix
    ./sshram.nix
  ];
}