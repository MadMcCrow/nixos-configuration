# home-manager/vs-code.nix
# 	vs code and all the extensions I Like
{ pkgs, lib, useVSCode ? true, ... }:
with builtins;
with lib;
let
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

  # git graph so view branches
  git-graph = vsMarketplace {
    name = "git-graph";
    publisher = "mhutchie";
    version = "1.30.0";
    sha256 = "sha256-sHeaMMr5hmQ0kAFZxxMiRk6f0mfjkg2XMnA4Gf+DHwA=";
  };

  # git history viewer
  git-history = vsMarketplace {
    name = "githistory";
    publisher = "donjayamanne";
    version = "0.6.19";
    sha256 = "sha256-YyEr4XRI2zzkzDXX2oS+jVnm5dggoZcS4Vc8mNSuQpc=";
  };

  # material-icons
  material-icons = vsMarketplace {
    name = "material-icon-theme";
    publisher = "PKief";
    version = "4.22.0";
    sha256 = "sha256-U9P9BcuZi+SUcvTg/fC2SkjGRD4CvgJEc1i+Ft2OOUc=";
  };

  # github-theme:  https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme
  github-theme = vsMarketplace {
    name = "github-vscode-theme";
    publisher = "GitHub";
    version = "6.3.4";
    sha256 = "sha256-JbI0B7jxt/2pNg/hMjAE5pBBa3LbUdi+GF0iEZUDUDM=";
  };

  # Sync settings
  sync-settings = vsMarketplace {
    name = "code-settings-sync";
    publisher = "Shan";
    version = "3.4.3";
    sha256 = "sha256-qmWL/IjPeoW57SpU0T9w1KMWuTlV6WTIlzB6vchwtHE=";
  };

  # Prettier : https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode
  prettier = vsMarketplace {
    name = "prettier-vscode";
    publisher = "esbenp";
    version = "9.12.0";
    sha256 = "sha256-b7EaYYJNZQBqhyKJ04tytmD9DDRcvA68HTo5JHTr9Fo=";
  };

  # MS intellicode
  intellicode = vsMarketplace {
    name = "vscodeintellicode";
    publisher = "VisualStudioExptTeam";
    version = "1.2.29";
    sha256 = "sha256-Wl++d7mCOjgL7vmVVAKPQQgWRSFlqL4ry7v0wob1OyU=";
  };

  # MS python
  ms-python = vsMarketplace {
    name = "python";
    publisher = "ms-python";
    version = "2023.9.11371007";
    sha256 = "sha256-kxzUrT3Q5aXCErozYLqB/quwxDFvItFl0R0iLwI7SKA=";
  };

  # MS cpp
  ms-cpp = vsMarketplace {
    name = "cpptools-extension-pack";
    publisher = "ms-vscode";
    version = "1.3.0";
    sha256 = "sha256-rHST7CYCVins3fqXC+FYiS5Xgcjmi7QW7M4yFrUR04U=";
  };

  # MS C#
  ms-dotnet = vsMarketplace {
    name = "csharp";
    publisher = "ms-dotnettools";
    version = "1.25.7";
    sha256 = "sha256-9jJ9qkjs+OX8m9nQA+/0leTWJPKqX/9L/F1bbfVosMM=";
  };

  # marketplace extensions
  marketPlaceExtensions = [
    godot-tools
    glsl-lint
    vs-shader
    shader-ed
    git-graph
    git-history
    material-icons
    github-theme
    prettier
    intellicode
    ms-python
    ms-cpp
    ms-dotnet
  ];

  # nixos extensions
  nixVsCodeExtensions = with pkgs.vscode-extensions; [
    jnoortheen.nix-ide
    rust-lang.rust-analyzer
    xaver.clang-format
    yzhang.markdown-all-in-one
    llvm-vs-code-extensions.vscode-clangd
    github.github-vscode-theme
  ];
in {
  # jetbrains mono font
  packages = [pkgs.jetbrains-mono];

  # vscode
  programs = {
    vscode = {
      enable = useVSCode;

      # disable update check and notification
      enableUpdateCheck = false;

      # use vscodium as vscode
      package = pkgs.vscodium;
      
      # allow installing extensions from marketplace
      mutableExtensionsDir = true;
      
      # enable extensions
      extensions = marketPlaceExtensions ++ nixVsCodeExtensions;

      # JSon settings 
      userSettings = {
        "update.mode" = "none";
        "workbench.iconTheme" = "material-icon-theme";
        "editor.fontSize" = 13;
        "editor.fontLigatures" = true;
        "editor.fontFamily" =  "'JetBrains Mono', 'Droid Sans Mono', 'monospace', monospace";
      };
    };
  };
}
