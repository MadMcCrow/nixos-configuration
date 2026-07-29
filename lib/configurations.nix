# configurations.nix
# use import-tree to import all our "fake" hosts
inputs@{
  self,
  lib,
  import-tree,
  ...
}:
with builtins;
let
  rootDir = self + "/hosts";
  inherit (import ./systems.nix inputs) mkSystem;
  mksysPair = path: {
    name = baseNameOf (dirOf path);
    value = lib.traceVal (mkSystem {
      config = path;
    });
  };
in
lib.traceVal (map mksysPair (import-tree.leafs rootDir))
