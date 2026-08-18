# flake part module for exposing lib
{
  inputs,
  self,
  ...
}:
with builtins;
let
  mksysPair = mod: {
    name = unsafeDiscardStringContext (baseNameOf (removeSuffix ".nix" mod));
    value = import mod inputs;
  };
in
{
  flake.lib = inputs.import-tree (i: i.map mksysPair) (i: i.leafs (self + "/lib"));
}
