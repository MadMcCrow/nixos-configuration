# vscode.nix
# 	Setup vscode and all it's things 
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  # config interface
  dev = config.apps.development;
  cfg = dev.vsCode;
  # marketplace extensions
  vsCodeGodotTools = (pkgs.vscode-utils.extensionFromVscodeMarketplace {
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
  # pakages to install
  packages = if cfg.extensions then
    (with pkgs;
      [
        (vscode-with-extensions.override {
          vscodeExtensions = nixVsCodeExtensions ++ [ vsCodeGodotTools ];
        })
      ])
  else
    [ vscode ];

in {
  # interface
  options.apps.development.vsCode = {
    enable = mkOption {
      type = types.bool;
      default = dev.enable;
      description = ''
        Add vscode.
      '';
    };
    extensions = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Add vscode extensions.
      '';
    };
  };
  # config
  config = mkIf cfg.enable {
    apps.packages = packages;
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
