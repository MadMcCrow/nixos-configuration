{
  pkgs ? import <nixpkgs> { },
  ...
}:
with builtins;
with pkgs;
let
  # local llm
  servai = callPackage ./packages/ai/llama-cpp.nix { };
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
    # ai server
    servai
  ];

  # start llm :
  shellHook = ''
    export SOME_API_TOKEN="$(cat ~/.config/some-app/api-token)"
    export NPINS_DIRECTORY="./packages/_npins"
    ${lib.getExe servai} &
  '';
}
