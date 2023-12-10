# shell environment to use/develop with secrets
{ pkgs, pycnix, ... }:
with builtins;
let
  # python scripts
  scripts = import ./scripts.nix { inherit pkgs pycnix; };

in pkgs.mkShell { buildInputs = attrValues scripts; }
