{ pkgs ? import <nixpkgs> {}, ... }:
with builtins;
let
  # local llm with llama-cpp
  autocomplete = pkgs.callPackage ./packages/ai/llama-cpp.nix {};
in
pkgs.mkShellNoCC {
  packages = (with pkgs; [
    # python dev
    uv
    python314
    ruff
    # nix dev
    deadnix
    statix
    nixfmt-rfc-style

    # Vulkan-SDK
      vulkan-headers
      vulkan-loader
      vulkan-tools

  ]) ++ [
    autocomplete
  ];

  # start llm :
  shellHook = ''
      ${pkgs.lib.getExe autocomplete}
      exit
  '';
}
