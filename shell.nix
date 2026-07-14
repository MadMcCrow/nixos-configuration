{
  pkgs ? import <nixpkgs> { },
  ...
}:
with builtins;
with pkgs;
let
  # local llm
  autocomplete = callPackage ./packages/_ai/ollama.nix { };
  npinupdate = callPackage ./packages/_npins/update.nix { rootDir = "./"; };
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
    npinupdate
  ];

  # start llm :
  shellHook = ''
    ${lib.getExe npinupdate}
    # ${lib.getExe autocomplete} &
  '';
}
