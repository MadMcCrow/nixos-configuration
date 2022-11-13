# vscode.nix
# 	Setup vscode and all it's things 
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
with pkgs.vscode-utils;
let
  # imports
  inherit imports;
  # marketplace extensions
  vscode.godotTools = (extensionFromVscodeMarketplace {
    name = "godot-tools";
    publisher = "geequlim";
    version = "1.3.1";
    sha256 = "e344cdf2fc7b29e0444136991dd8a93efba9c4e9";
  });

  # nixos extensions
  vscode.extensions = with vscode-extensions; [
    jnoortheen.nix-ide
    ms-python.python
    rust-lang.rust-analyzer
    ms-vscode.cpptools
    xaver.clang-format
    llvm-vs-code-extensions.vscode-clangd
  ];

  # final package
  vscode.packages = with pkgs;
    [
      (vscode-with-extensions.override {
        vscodeExtensions = vscode.extensions ++ vscode.godotTools;
      })
    ];
  # unfree predicate
  vscode.unfree = [
    "vscode"
    "vscode-with-extensions"
    "jnoortheen.nix-ide"
    "ms-python.python"
    "rust-lang.rust-analyzer"
    "ms-vscode.cpptools"
    "xaver.clang-format"
    "llvm-vs-code-extensions.vscode-clangd"
    "vscode-extension-ms-vscode-cpptools"
  ];
in {
  # do nothing
}
