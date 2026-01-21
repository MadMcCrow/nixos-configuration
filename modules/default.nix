# Modules :
# provide simple methods to unify all declaration
{ _ }:
let
  # create the attribute set for "nixpkgs.lib.nixosSystem"
  mkSystemArgs = { moduleNames, config, extraArgs ? {}, overrides ? {} } :
  {
    specialArgs = extraArgs;
    modules = (map (x: ./ + x ) moduleNames) ++ [config];
  };
in
{
  # TODO :
  # A/B config, without store
  applianceSystem = systemArgs :
    nixpkgs.lib.nixosSystem ({
          system = "x86_64-linux";
        } // mkSystemArgs args);

  # "traditional" nixos configuration
  nixosSystem = systemArgs :
  nixpkgs.lib.nixosSystem ({
        system = "x86_64-linux";
      } // mkSystemArgs systemArgs);
}
