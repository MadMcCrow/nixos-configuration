# vscode.nix
# 	Setup vscode and all it's things 
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  # config interface
  dev = config.apps.development;
  cfg = dev.vsCode;
  # Market place getter
  vsMarketplace = pkgs.vscode-utils.extensionFromVscodeMarketplace;
  # godot support
  godot-tools = vsMarketplace {
    name = "godot-tools";
    publisher = "geequlim";
    version = "1.3.1";
    sha256 = "sha256-wJICDW8bEBjilhjhoaSddN63vVn6l6aepPtx8VKTdZA=";
  };
  # GLSL linter
  glsl-lint = vsMarketplace {
    name = "vscode-glsllint";
    publisher = "dtoplak";
    version = "1.8.0";
    sha256 = "sha256-imB+S7N6TIuyhMw/tfLdtGnLTgLv6BL9IAxKrOzICj8=";
  };
  # support for shader languages
  vs-shader = vsMarketplace {
    name = "shader";
    publisher = "slevesque";
    version = "1.1.5";
    sha256 = "sha256-Pf37FeQMNlv74f7LMz9+CKscF6UjTZ7ZpcaZFKtX2ZM=";
  };
  # editor for shader
  shader-ed = vsMarketplace {
    name = "shadered";
    publisher = "dfranx";
    version = "0.0.5";
    sha256 = "sha256-0X6D7jhJ54DOVjw+M5D6Z4YbaZnp5/l2ACPyQj3xywo=";
  };
  # intellicode form MS
  intellicode = vsMarketplace {
    name = "vscodeintellicode";
    publisher = "VisualStudioExptTeam";
    version = "1.2.29";
    sha256 = "sha256-Wl++d7mCOjgL7vmVVAKPQQgWRSFlqL4ry7v0wob1OyU=";
  };
  # pull-request support for PRs
  gh-pullrequest = vsMarketplace {
    name = "vscode-pull-request-github";
    publisher = "github";
    version = "0.54.1";
    sha256 = "sha256-AhsKTjIhyhGW9KcqAhWAzYAOv/wuQvNFKWlPmiK7hUQ=";
  };
  # vscode-icons fir better icons
  vscode-icons = vsMarketplace {
    name = "vscode-icons";
    publisher = "vscode-icons-team";
    version = "12.0.1";
    sha256 = "sha256-zxKD+8PfuaBaNoxTP1IHwG+25v0hDkYBj4RPn7mSzzU=";
  };
  # other nice icon
  jtlowe-icons = vsMarketplace {
    name = "vscode-icon-theme";
    publisher = "jtlowe";
    version = "1.6.6";
    sha256 = "sha256-zB4xBoCgdTyIegwrvu2Od4/QK4ZttV1OXWfo0MMKhLA=";
  };
  # material-icons
  material-icons = vsMarketplace {
    name = "material-icon-theme";
    publisher = "PKief";
    version = "4.22.0";
    sha256 = "sha256-U9P9BcuZi+SUcvTg/fC2SkjGRD4CvgJEc1i+Ft2OOUc=";
  };
  # mutable AI code completion
  mutable-ai = vsMarketplace {
    name = "mutable-ai";
    publisher = "mutable-ai";
    version = "1.2.4";
    sha256 = "sha256-7csm30aRvb2a8FV3n8VgcO8+/OY6adQfz/u34bl3D7E=";
  };
  # codiga AI
  codiga = vsMarketplace {
    name = "vscode-plugin";
    publisher = "codiga";
    version = "0.8.8";
    sha256 = "sha256-eaC03cZa8uVuZPmhOw7qgwrvbci+I0pWhT3DsNkMs9U=";
  };

  # marketplace extensions
  marketPlaceExtensions = [
    godot-tools
    glsl-lint
    vs-shader
    shader-ed
    intellicode
    gh-pullrequest
    vscode-icons
    jtlowe-icons
    material-icons
    mutable-ai
    codiga
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
