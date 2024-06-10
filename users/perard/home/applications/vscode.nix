# home-manager/vs-code.nix
# 	vs code and all the extensions I Like
{ pkgs, lib, config, pkgs-latest, ... }:
let

  # Market place getter
  vsMarketplace = pkgs.vscode-utils.extensionFromVscodeMarketplace;

  # https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools
  godot-tools = vsMarketplace {
    name = "godot-tools";
    publisher = "geequlim";
    version = "2.0.0";
    sha256 = "sha256-6lSpx6GooZm6SfUOjooP8mHchu8w38an8Bc2tjYaVfw=";
  };

  # https://marketplace.visualstudio.com/items?itemName=alfish.godot-files
  godot-files = vsMarketplace {
    name = "godot-files";
    publisher = "alfish";
    version = "0.0.8";
    sha256 = "sha256-Ih7yBCVQepBT8JY+k+KgGZw+cFhfFlhifZTF8h7tBXs=";
  };

  # quite old (2021)
  # https://marketplace.visualstudio.com/items?itemName=dfranx.shadered
  shader-ed = vsMarketplace {
    name = "shadered";
    publisher = "dfranx";
    version = "0.0.5";
    sha256 = "sha256-0X6D7jhJ54DOVjw+M5D6Z4YbaZnp5/l2ACPyQj3xywo=";
  };

  # less old (2022)
  # https://marketplace.visualstudio.com/items?itemName=circledev.glsl-canvas
  glsl-canvas = vsMarketplace {
    name = "glsl-canvas";
    publisher = "circledev";
    version = "0.2.15";
    sha256 = "";
  };

  # git graph so view branches
  # consider moving to https://marketplace.visualstudio.com/items?itemName=d-bassarab.yagg
  git-graph = vsMarketplace {
    name = "git-graph";
    publisher = "mhutchie";
    version = "1.30.0";
    sha256 = "sha256-sHeaMMr5hmQ0kAFZxxMiRk6f0mfjkg2XMnA4Gf+DHwA=";
  };

  # https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory
  git-history = vsMarketplace {
    name = "githistory";
    publisher = "donjayamanne";
    version = "0.6.20";
    sha256 = "sha256-nEdYS9/cMS4dcbFje23a47QBZr9eDK3dvtkFWqA+OHU=";
  };

  # https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme
  material-icons = vsMarketplace {
    name = "material-icon-theme";
    publisher = "PKief";
    version = "5.2.0";
    sha256 = "sha256-OxJ0+cupnkNczwfE0QGqL9dRja0QLZc+z0TaHm02ezY=";
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
    version = "0.0.73";
    sha256 = "sha256-83qz4wYnRK/KtrQMHwMAFhOnVyLXG1/EwUvVW2v30ho=";
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

  haxe-checkstyle = vsMarketplace {
    name = "haxe-checkstyle";
    publisher = "vshaxe";
    version = "1.8.3";
    sha256 = "sha256-oOo7o1k0Er1txWUf69R6HuKyqpHwlpAol54KpKiWehk=";
  };

  #
  jetbrainsColors = vsMarketplace {
    name = "jetbrains-new-dark";
    publisher = "MoBalic";
    version = "0.0.1";
    sha256 = "sha256-hp1RoOacqM016NEtGXhdza4LxHZ0/rxyrTI2pwpjnas=";
  };

  # https://marketplace.visualstudio.com/items?itemName=Leathong.openscad-language-support
  openscad = vsMarketplace {
    name = "openscad";
    publisher = "Antyos";
    version = "1.3.0";
    sha256 = "sha256-GY5GHZWxMuEPL+cyxj2jeLtUjxfjPTtj0eUZcyViqO8=";
  };

  # https://marketplace.visualstudio.com/items?itemName=Antyos.openscad
  openscad-language-support = vsMarketplace {
    name = "openscad-language-support";
    publisher = "Leathong";
    version = "1.2.5";
    sha256 = "sha256-/CLxBXXdUfYlT0RaGox1epHnyAUlDihX1LfT5wGd2J8=";
  };

in {
  programs.vscode = {
    enable = true;
    # disable update check and notification
    enableUpdateCheck = false;
    # use vscodium as vscode
    package = pkgs-latest.vscodium;
    # allow installing extensions from marketplace
    mutableExtensionsDir = false;
    # enable extensions
    extensions = with pkgs-latest.vscode-extensions;
      [
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        xaver.clang-format
        llvm-vs-code-extensions.vscode-clangd
        github.github-vscode-theme
      ] ++ [
        godot-tools
        godot-files
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
        # github-action -> slow
        github-markdown
        github-remotehub
        haxe-checkstyle
        jetbrainsColors
        # scad :
        # openscad
        # openscad-language-support
      ];

    # JSon settings
    userSettings = {
      "anycode.language.features" = {
        "diagnostics" = true;
        "folding" = true;
      };
      "diffEditor.codeLens" = true;
      "editor.fontFamily" = "'JetBrains Mono', 'Droid Sans Mono', monospace";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 13;
      "editor.tabCompletion" = "on";
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
      "window.restoreWindows" = "none";
      "window.titleBarStyle" = "native";
      "window.zoomLevel" = 3;
      "workbench.colorCustomizations" = {
        "activityBar.activeBackground" = "#0000002C";
        "tab.inactiveBackground" = "#00000041";
      };
      "workbench.colorTheme" = "GitHub Dark";
      "workbench.iconTheme" = "material-icon-theme";
      "terminal.integrated.customGlyphs" = false;
      "terminal.integrated.fontFamily" =
        "'JetBrains Mono NF Medium', 'JetBrains Mono'";
      # something that could be done for colors :
      # "editor.tokenColorCustomizations" ={
      # "functions"= "#179559";
      # "numbers"= "#fff476";
      # "types"= "#ff7f50";
      # "comments"= "#555555";
      # "variables"= "#ffffff";
      # "keywords"= "#226f50";
      # };
    };
  };
}
