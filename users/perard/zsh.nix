# home-manager/zsh.nix
#   a modern shell
# TODO : share  with other users
{ pkgs }:
with builtins;
with pkgs;
with pkgs.lib;
let

  autosuggestions = {
    name = "zsh-autosuggestions";
    src = pkgs.zsh-autosuggestions;
  };
  syntax-highlighting = {
    name = "zsh-syntax-highlighting";
    src = pkgs.zsh-syntax-highlighting;
  };

  # powerline go for bash in every shell
  powerline-go-bash-init = ''
        # Workaround for nix-shell --pure
    if [ "$IN_NIX_SHELL" == "pure" ]; then
        if [ -x "$HOME/.nix-profile/bin/powerline-go" ]; then
            alias powerline-go="$HOME/.nix-profile/bin/powerline-go"
        elif [ -x "/run/current-system/sw/bin/powerline-go" ]; then
            alias powerline-go="/run/current-system/sw/bin/powerline-go"
        fi
    fi
  '';
in {
  packages =  [
    exa
    powerline-go
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  programs = {
    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      enableSyntaxHighlighting = true;

      # better navigation
      #shellAliases = { 
      # already done by exa.enableAliases = true;
      #  ls = "exa";
      #};
      autocd = true;

      # smaller history
      history = {
        size = 100;
        ignoreDups = true;
        ignoreSpace = true;
        extended = false;
        share = true;
      };

      # manual plugins setup
      plugins = [ autosuggestions syntax-highlighting ];

      #initExtra = ''
      #  source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      #  source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      #'';

    };

    # Bash And Zsh shell history suggest box
    hstr.enable = true; # only in 23.05

    # Powerline go is another alternative
    # supposedly faster than omz and omp
    powerline-go = {
      enable = true;
      # modules : aws, bzr, cwd, direnv, docker, docker-context, dotenv, duration, exit, fossil, gcp, git, gitlite, goenv, hg, host, jobs, kube, load, newline, nix-shell, node, perlbrew, perms, plenv, rbenv, root, rvm, shell-var, shenv, ssh, svn, termtitle, terraform-workspace, time, user, venv, vgo, vi-mode, wsl)
      # (default "venv,user,host,ssh,cwd,perms,git,hg,jobs,exit,root")
      #modules-right : aws, bzr, cwd, direnv, docker, docker-context, dotenv, duration, exit, fossil, gcp, git, gitlite, goenv, hg, host, jobs, kube, load, newline, nix-shell, node, perlbrew, perms, plenv, rbenv, root, rvm, shell-var, shenv, ssh, svn, termtitle, terraform-workspace, time, user, venv, vgo, wsl)
      modules = [ "user" "host" "nix-shell" "cwd" "gitlite" "root" ];
      modulesRight = [ "exit" "time" ];
      settings = {
        hostname-only-if-ssh = true;
        numeric-exit-codes = true;
        cwd-max-depth = 3;
        git-mode = "compact";
        priority = [ "root" "cwd" "user" "nix-shell" "gitlite" ];
        # duration needs a way to get last command time and there's no explaination on how to do it.
        #duration = "1";
        #duration-low-precision = true;
        #duration-min = "1";
      };
    };

    # bash is used in nix-shell
    bash = {
      # enable powerline-go in bash
      bashrcExtra = powerline-go-bash-init;
      #historyFile = ".bash"
    };

    # exa is ls but improved
    exa = {
      enable = true;
      enableAliases = true;
      git = true;
      extraOptions = [ "--group-directories-first" "--header" ];
    };

    # environment switcher
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
