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
      name = "vscode-glsllint";
      publisher = "dtoplak";
      version = "1.8.0";
      sha256 = "sha256-imB+S7N6TIuyhMw/tfLdtGnLTgLv6BL9IAxKrOzICj8=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "vscodeintellicode";
      publisher = "VisualStudioExptTeam";
      version = "1.2.29";
      sha256 = "sha256-Wl++d7mCOjgL7vmVVAKPQQgWRSFlqL4ry7v0wob1OyU=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "vscode-pull-request-github";
      publisher = "github";
      version = "0.54.1";
      sha256 = "sha256-AhsKTjIhyhGW9KcqAhWAzYAOv/wuQvNFKWlPmiK7hUQ=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "shader";
      publisher = "slevesque";
      version = "1.1.5";
      sha256 = "sha256-Pf37FeQMNlv74f7LMz9+CKscF6UjTZ7ZpcaZFKtX2ZM=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "shadered";
      publisher = "dfranx";
      version = "0.0.5";
      sha256 = "sha256-0X6D7jhJ54DOVjw+M5D6Z4YbaZnp5/l2ACPyQj3xywo=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "12.0.1";
      sha256 = "sha256-zxKD+8PfuaBaNoxTP1IHwG+25v0hDkYBj4RPn7mSzzU=";
    })
    (pkgs.vscode-utils.extensionFromVscodeMarketplace {
      name = "stepsize";
      publisher = "Stepsize";
      version = "0.72.0";
      sha256 = "sha256-XTWuYQIuDeb+aZVTeWdfxJLnLs+5BKxBrJC5IjYgBQU=";
    })
  ];
  # nixos extensions
  nixVsCodeExtensions = with pkgs.vscode-extensions; [
    jnoortheen.nix-ide
    ms-python.python
    rust-lang.rust-analyzer
    ms-vscode.cpptools
    xaver.clang-format
    yzhang.markdown-all-in-one
    llvm-vs-code-extensions.vscode-clangd
    github.github-vscode-theme
    github.codespaces
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
      "vscode-extension-ms-vscode-cpptools"
      "vscode-extension-github-codespaces"
    ];
  };
}
