# configurations.nix
# use import-tree to import all our "fake" hosts
inputs@{
  self,
  lib,
  import-tree,
  ...
}:
with builtins;
with lib;
let
  # use our wrapper to build the nixOS hosts
  inherit (import ./systems.nix inputs) mkSystem;

  mksysPair = mod: rec {
    name = unsafeDiscardStringContext (baseNameOf (removeSuffix ".nix" mod));
    value = mkSystem { modules = [ mod ]; };
  };

  # find all configurations
  configurations = import-tree.leafs (self + "/checks");
in
# build attrset
listToAttrs (map mksysPair configurations)
