# mkAppliance.nix
# make a custom appliance system (ie. no nix store)
{nixpkgs, ...}@args:
let
  err = throw "not implemented yet !"
in
systemArgs: nixpkgs.lib.nixosSystem (mkConfig systemArgs)
