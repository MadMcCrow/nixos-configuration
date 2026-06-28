# mkSystem.nix
#   base function to build an host
# returns :
#   all the meaningful outputs
{ nixpkgs, ... }@args:
let
  mkConfig = import ./mkConfig.nix args;
  nixosSystem = tomlPath: (nixpkgs.lib.nixosSystem (mkConfig tomlPath));
in
nixosSystem;
