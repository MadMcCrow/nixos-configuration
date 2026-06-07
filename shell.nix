{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    # python dev
    uv
    python314
    ruff
    # nix dev
    deadnix
    statix
    nixfmt-rfc-style
  ];
}
