{
  pkgs ? import <nixpkgs> { },
  ...
}:
with builtins;
with pkgs;
let
  # local llm
  autocomplete = callPackage ./packages/_ai/ollama.nix { };
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
    nixfmt-tree
    npins
    # our dev package helpers
    autocomplete
  ];

  # start llm :
  shellHook = ''
     export SOME_API_TOKEN="$(cat ~/.config/some-app/api-token)"
     export NPINS_DIRECTORY="./packages/_npins"
    # ${lib.getExe autocomplete} &
    ${lib.getExe nixfmt-tree}
  '';
}
