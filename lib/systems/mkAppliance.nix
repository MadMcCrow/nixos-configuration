# mkAppliance.nix
# make a custom appliance system (ie. no nix store)
{ nixpkgs, ...}:
let
  mkSystemArgs = import ./args.nix args ;
in
# TODO :
# A/B config, without store
  systemArgs :
    nixpkgs.lib.nixosSystem ({
          system = "x86_64-linux";
        } // mkSystemArgs args);
