# flake part module for building test configurations
{
  self,
  inputs,
  ...
}:
with builtins;
with inputs.nixpkgs.lib;
let
  # use template pins (slightly outdated) :
  #  (import (self + "/ostool/template/npins")) //
  sources = {
    inherit (inputs) nixpkgs;
    nonOS = self;
  };
  # map outputs
  mksysPair = mod: {
    name = unsafeDiscardStringContext (baseNameOf (removeSuffix ".nix" mod));
    value = nixosSystem { modules = [ (import mod sources) ]; };
  };
  # find all configurations
  configurations = inputs.import-tree.leafs (self + "/checks");
in
{
  flake.nixosConfigurations = listToAttrs (map mksysPair configurations);
}
