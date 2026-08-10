# shell to work on the whole project
inputs@{
  pkgs ? import <nixpkgs> { },
  ...
}:
with builtins;
with pkgs;
let
  # local llm
  servai         = callPackage ../packages/ai/llama-cpp.nix inputs;
  # update packages pins
  pkgsupd = callPackage ../packages/_npins/update.nix inputs;
  # update template pins
  tpltupd = callPackage ../tools/init/template/update.nix inputs;

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
    # shell
    just
    shellcheck
    # deadnix
    statix
    nixfmt-tree
    nixos-install-tools
    npins
    just
    # our tools :
    servai
    pkgsupd
    tpltupd
  ];
}
