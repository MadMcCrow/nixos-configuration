# flake part module for building test configurations
{
  self,
  inputs,
  ...
}:
with builtins;
with inputs.nixpkgs.lib;
let
    mksysPair = mod: {
      name = unsafeDiscardStringContext (baseNameOf (removeSuffix ".nix" mod));
      value = nixosSystem {modules = [mod];};
    };
    # find all configurations
    configurations = inputs.import-tree.leafs (self + "/checks");
in
{
  flake.nixosConfigurations = listToAttrs (map mksysPair configurations);
}
