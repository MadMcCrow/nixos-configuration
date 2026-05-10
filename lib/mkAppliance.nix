# mkAppliance.nix
# make a custom appliance system (ie. no nix store)
args:
let
  mkConfig = import ./mkConfig.nix args;
  # TODO :
  # A/B config, without store
in
systemArgs: nixpkgs.lib.nixosSystem (mkConfig systemArgs)
