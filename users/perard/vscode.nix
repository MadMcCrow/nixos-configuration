# home-manager/vs-code.nix
# 	vs code and all the extensions I Like
{ pkgs }:
with builtins;
with pkgs.lib;
let

  # Json settings for VS Code
  vsSettings = {
    "editor.fontFamily" = "'JetBrains Mono', 'Droid Sans Mono', monospace";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 13;
    "editor.tabCompletion" = "on";
    "diffEditor.codeLens" = true;
    "update.mode" = "none";
    "window.titleBarStyle" = "native"; # use "custom" for vs-code title bar
    "window.restoreWindows" = "none";
    "window.zoomLevel" = 2;
    "workbench.colorTheme" = "GitHub Dark";
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.colorCustomizations" = {
      "activityBar.activeBackground" = "#0000002C";
      "tab.inactiveBackground" = "#00000041"; # make tabs pop more
    };
    # something that could be done for colors :
    # "editor.tokenColorCustomizations" ={
    # "functions"= "#179559";
    # "numbers"= "#fff476";
    # "types"= "#ff7f50";
    # "comments"= "#555555";
    # "variables"= "#ffffff";
    # "keywords"= "#226f50";
    # };
    "anycode.language.features" = {
      "folding" = true;
      "diagnostics" = true;
    };
  };

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
    version = "0.6.20";
    sha256 = "sha256-nEdYS9/cMS4dcbFje23a47QBZr9eDK3dvtkFWqA+OHU=";
  };

  # material-icons
  material-icons = vsMarketplace {
    name = "material-icon-theme";
    publisher = "PKief";
    version = "4.28.0";
    sha256 = "sha256-DO3dcJPk+TMhfb0IJ/eTB7nIKfyCXIiyhZFBpZjJzsM=";
  };

  # material-theme
  material-theme = vsMarketplace {
    name = "vsc-community-material-theme";
    publisher = "Equinusocio";
    version = "1.4.6";
    sha256 = "sha256-DVgyE9CAB7m8VzupUKkYIu3fk63UfE+cqoJbrUbdZGw=";
  };

  # an old hope theme : https://marketplace.visualstudio.com/items?itemName=dustinsanders.an-old-hope-theme-vscode;
  an-old-hope = vsMarketplace {
    name = "an-old-hope-theme-vscode";
    publisher = "dustinsanders";
    version = "4.4.0";
    sha256 = "sha256-G4JecJhVciNy9I4WW3Wkf/QVyxXatJ+FasBikWsYeRk=";
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

  # Peacock : https://marketplace.visualstudio.com/items?itemName=johnpapa.vscode-peacock
  peacock = vsMarketplace {
    name = "vscode-peacock";
    publisher = "johnpapa";
    version = "4.2.2";
    sha256 = "sha256-VTRTQpIiFUxc3qF+E1py1+ns93i918QeTAoWAf7NLP0=";
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

  # Anycode code searches : https://marketplace.visualstudio.com/items?itemName=ms-vscode.anycode
  ms-anycode = vsMarketplace {
    name = "anycode";
    publisher = "ms-vscode";
    version = "0.0.72";
    sha256 = "sha256-LV3kyLWRd+yLtIOKB7zOdlCX5NO5RiGcBab09lyeO6A=";
  };

  # github https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github
  github-pr = vsMarketplace {
    name = "vscode-pull-request-github";
    publisher = "GitHub";
    version = "0.71.2023090509";
    sha256 = "sha256-h6AVwUYDrLuZTnzGuR3oWyL2XqxjFdJMXvjwikp6BuY=";
  };

  # github action : https://marketplace.visualstudio.com/items?itemName=github.vscode-github-actions
  github-action = vsMarketplace {
    name = "vscode-github-actions";
    publisher = "GitHub";
    version = "0.25.7";
    sha256 = "sha256-MZrpaWe9PE+S4pRcSxLA417gQL0/oXvnZv+vSrb9nec=";
  };

  # Codespaces : https://marketplace.visualstudio.com/items?itemName=GitHub.codespaces
  github-codespaces = vsMarketplace {
    name = "codespaces";
    publisher = "GitHub";
    version = "1.15.0";
    sha256 = "sha256-XHVZ9H+F5s9EMkyrjw3sQYdi70mlGf/MmlZOR88NlAw=";
  };

  # remote hub : https://marketplace.visualstudio.com/items?itemName=GitHub.remotehub
  github-remotehub = vsMarketplace {
    name = "remotehub";
    publisher = "GitHub";
    version = "0.61.2023081601";
    sha256 = "sha256-98BfGCxwlt0Jct23BltWKbcT0eiygTgANvrFPat+0bo=";
  };

  github-markdown = vsMarketplace {
    name = "github-markdown-preview";
    publisher = "bierner";
    version = "0.3.0";
    sha256 = "sha256-7pbl5OgvJ6S0mtZWsEyUzlg+lkUhdq3rkCCpLsvTm4g=";
  };

  haxe = vsMarketplace {
    name = "vshaxe";
    publisher = "nadako";
    version = "2.30.0";
    sha256 = "sha256-tzcX9sWjbA64bFeq8FV7l39p16nzYhvwHO3mvEleH1o=";
  };
  haxe-lint = vsMarketplace {
    name = "haxe-checkstyle";
    publisher = "vshaxe";
    version = "1.8.3";
    sha256 = "";
  };

  jetbrainsColors = vsMarketplace {
    name = "jetbrains-new-dark";
    publisher = "MoBalic";
    version = "0.0.1";
    sha256 = "";
  };

  # marketplace extensions
  marketPlaceExtensions = [
    godot-tools
    glsl-lint
    vs-shader
    shader-ed
    git-graph
    material-icons
    intellicode
    haxe
    ms-python
    ms-cpp
    ms-dotnet
    ms-anycode
    github-pr
    github-codespaces
    github-action
    github-markdown
    github-remotehub
  ];

  # nixos extensions
  nixVsCodeExtensions = with pkgs.vscode-extensions; [
    jnoortheen.nix-ide
    rust-lang.rust-analyzer
    xaver.clang-format
    llvm-vs-code-extensions.vscode-clangd
    github.github-vscode-theme
  ];
in {
  enable = true;
  # disable update check and notification
  enableUpdateCheck = false;
  # use vscodium as vscode
  package = pkgs.vscodium;
  # allow installing extensions from marketplace
  mutableExtensionsDir = false;
  # enable extensions
  extensions = marketPlaceExtensions ++ nixVsCodeExtensions;
  # JSon settings
  userSettings = vsSettings;
}
