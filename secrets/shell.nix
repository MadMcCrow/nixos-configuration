# shell environment to use/develop with secrets
{ pkgs, pycnix, ... }:
let
  # python scripts
  scripts = import ./scripts.nix { inherit pkgs pycnix; };

in pkgs.mkShell { buildInputs = builtins.attrValues scripts; }
