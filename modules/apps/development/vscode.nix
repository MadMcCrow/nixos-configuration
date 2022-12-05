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
  marketPlaceExtensions = [
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "godot-tools";
      publisher = "geequlim";
      version = "1.3.1";
      sha256 = "sha256-wJICDW8bEBjilhjhoaSddN63vVn6l6aepPtx8VKTdZA=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "github-vscode-theme";
      publisher = "GitHub";
      version = "6.3.2";
      sha256 = "sha256-CbFZsoRiiwSWL7zJdnBcfrxuhE7E9Au2AlQjqYXW+Nc=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "vscode-pull-request-github";
      publisher = "GitHub";
      version = "0.55.2022120509";
      sha256 = "sha256-48C9g+ij5YuZSgcNvwltx+xVuaAnpV/f4uMmWV66NtM=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "vscodeintellicode";
      publisher = "VisualStudioExptTeam";
      version = "1.2.29";
      sha256 = "sha256-Wl++d7mCOjgL7vmVVAKPQQgWRSFlqL4ry7v0wob1OyU=";
    })
  ];
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
          vscodeExtensions = nixVsCodeExtensions ++ marketPlaceExtensions;
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
