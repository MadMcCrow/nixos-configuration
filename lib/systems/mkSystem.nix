# mkSystem.nix
# base function to build an host
{ nixpkgs, ... } @args:
let
  mkConfig = import ./mkConfig.nix args;
in
tomlPath:
  nixpkgs.lib.nixosSystem (mkConfig tomlPath)
