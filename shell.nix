{ pkgs ? import <nixpkgs> {}, ... }:
with builtins;
with pkgs;
let
  # local llm
  autocomplete = callPackage ./packages/_ai/ollama.nix {};
  npin-update = callPackage ./packages/_npins/update.nix {};
in
mkShellNoCC {
  packages = [
    # python dev
    uv
    python314
    ruff
    # nix dev
    deadnix
    statix
    nixfmt-rfc-style
    # our dev package helpers
    autocomplete
    npins-update
  ];

  # start llm :
  shellHook = ''
      #
      # ${pkgs.lib.getExe autocomplete} &
  '';
}
