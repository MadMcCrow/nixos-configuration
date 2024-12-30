{ pkgs, lib, ... }:
{
  programs = {
    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      autosuggestion.enable = true;
      enableCompletion = true;
      oh-my-zsh.enable = true;
      # add profiling
      zprof.enable = true;
      # initExtraFirst = "";
      autocd = true;
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
      history = {
        size = 100;
        ignoreDups = true;
        ignoreSpace = true;
        extended = false;
        share = true;
      };
      # alias vscodium to vscode
      shellAliases = rec {
        #code = "codium";
        ls = "${lib.getExe pkgs.eza}";
        exa = ls;
        htop = "${lib.getExe pkgs.btop}";
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

    # bash is used in nix-shell
    bash = {
      # enable powerline-go in bash
      bashrcExtra = ''
            # Workaround for nix-shell --pure
        if [ "$IN_NIX_SHELL" == "pure" ]; then
            if [ -x "$HOME/.nix-profile/bin/powerline-go" ]; then
                alias powerline-go="$HOME/.nix-profile/bin/powerline-go"
            elif [ -x "/run/current-system/sw/bin/powerline-go" ]; then
                alias powerline-go="/run/current-system/sw/bin/powerline-go"
            fi
        fi
      '';
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
