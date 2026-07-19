# test/default.nix
# make a list of all the test configs
inputs@{
  self,
  import-tree,
  pkgs,
  lib,
  ...
}:
let
  systems = import (self + "/lib/system.nix") inputs;
  mkTestDerivation = toml: {
    name = lib.removeSuffix ".toml" (builtins.baseNameOf toml);
    value = with systems; joinSystemOutputs (mkNixosSystem toml);
  };
in
builtins.listToAttrs (
  import-tree (i: i.initFilter (lib.hasSuffix ".toml")) (i: i.map lib.traceVal) (
    i: i.map mkTestDerivation
  ) (i: i.withLib lib) (i: i.leafs ./.)
)
