# mkAppliance.nix
# make a custom appliance system (ie. no nix store)
args :
let
  mkSystemArgs = import ./args.nix args;
  # TODO :
  # A/B config, without store
in systemArgs:
nixpkgs.lib.nixosSystem ({ system = "x86_64-linux"; } // mkSystemArgs systemArgs)
