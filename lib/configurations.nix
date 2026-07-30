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
    name = unsafeDiscardStringContext (baseNameOf (dirOf mod));
    value = mkSystem { modules = [ mod ]; };
  };

  # find all configurations
  configurations = import-tree (i: i.initFilter (x: match ("configuration.nix" x) != null)) (
    i: i.leafs (self + "/hosts")
  );
in
# build attrset
listToAttrs (map mksysPair configurations)
