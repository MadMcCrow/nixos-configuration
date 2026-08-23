# flake part module for exposing nixosModules
{
  self,
  inputs,
  ...
}:
with builtins;
let
  inherit (inputs.nixpkgs) lib;
  nonOS = import (self + "/lib/nonOS.nix") (inputs // { inherit lib; });
  manifest = import (self + "/modules/manifest.nix") (inputs // { inherit lib nonOS; });
in
rec {
  flake = {
    nixosModules = mapAttrs (_k: v: (_: { imports = v; })) (
      manifest // { "default" = lib.concatAttrValues manifest; }
    );
    moduleOptions =
      (lib.evalModules {
        modules = [ flake.nixosModules.default ];
      }).options;
  };
}
