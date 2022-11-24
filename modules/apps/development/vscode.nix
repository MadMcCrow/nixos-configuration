# vscode.nix
# 	Setup vscode and all it's things 
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
with pkgs.vscode-utils;
let
  # marketplace extensions
  vsCodeGodotTools = (extensionFromVscodeMarketplace {
    name = "godot-tools";
    publisher = "geequlim";
    version = "1.3.1";
    sha256 = "sha256-wJICDW8bEBjilhjhoaSddN63vVn6l6aepPtx8VKTdZA=";
  });
  # nixos extensions
  nixVsCodeExtensions = with pkgs.vscode-extensions; [
    jnoortheen.nix-ide
    ms-python.python
    rust-lang.rust-analyzer
    ms-vscode.cpptools
    xaver.clang-format
    llvm-vs-code-extensions.vscode-clangd
  ];

in {

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        (vscode-with-extensions.override {
          vscodeExtensions = nixVsCodeExtensions ++ [ vsCodeGodotTools ];
        })
      ];
    # unfree predicate
    unfree.unfreePackages = [
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
  };
}
