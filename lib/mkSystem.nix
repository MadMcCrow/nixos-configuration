# mkSystem.nix
#   base function to build an host
# returns :
#   the top level of the config
{ nixpkgs, ... }@args:
let
  mkConfig = import ./mkConfig.nix args;
in
tomlPath: (nixpkgs.lib.nixosSystem (mkConfig tomlPath)).config.system.build.toplevel
