{ pkgs, lib, ... }:
{
  programs = {
    zsh = {
      autocd = true;
      autosuggestion.enable = true;
      dotDir = ".config/zsh";
      enable = true;
      enableCompletion = true;

      history = {
        size = 100;
        ignoreDups = true;
        ignoreSpace = true;
        extended = false;
        share = true;
      };

      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.8.0";
            hash = "sha256-Z6EYQdasvpl1P78poj9efnnLj7QQg13Me8x1Ryyw+dM=";
          };
        }
      ];
      #
      # prezto is faster than OMZ
      prezto.enable = true;

      # profiling :
      # zprof.enable = true;

      # alias vscodium to vscode
      shellAliases = rec {
        #code = "codium";
        ls = "${lib.getExe pkgs.eza}";
        exa = ls;
        htop = "${lib.getExe pkgs.btop}";
        #TODO : add a "get colors tool"
        #colors=''for x in {0..99}; do printf "\033[;${x}m $x \033[;0m"; done'';
      };
      syntaxHighlighting.enable = true;
    };

    # eza is ls but improved
    eza = {
      enable = true;
      # programs.eza.enableBashIntegration <- defaults to true
      git = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    # fuzzy search :
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    # Bash And Zsh shell history suggest box
    hstr = {
      enable = true;
      enableZshIntegration = true;
    };

    # environment switcher
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    powerline-go = {
      enable = true;
      modules = [
        "user"
        "host"
        "nix-shell"
        "cwd"
        "gitlite"
        "root"
      ];
      modulesRight = [
        "exit"
        "time"
      ];
      settings = {
        hostname-only-if-ssh = true;
        numeric-exit-codes = true;
        cwd-max-depth = 3;
        git-mode = "compact";
        priority = [
          "root"
          "cwd"
          "user"
          "nix-shell"
          "gitlite"
        ];
      };
    };

    # better htop
    btop = {
      enable = true;
      settings = {
        color_theme = "Default";
        theme_background = false;
      };
    };
  };
}
