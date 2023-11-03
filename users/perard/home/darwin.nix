# darwin.nix
# home manager configuration for MacOS
# TODO : browser 
{ config, pkgs, ... }:
{
  home.username = "perard";
  home.homeDirectory = "/Users/perard";
  home.stateVersion = "23.05";

  imports = [./shared.nix];

  # packages to install to profile (extra to shared)
  home.packages = (with pkgs; [
    exa
  ]);

  # Programs setup :
  # vscode is in another module (too many extensions)
  programs.vscode = (import ./vscode.nix { inherit pkgs; });

  # GIT
  programs.git = {
    enable = true;
    userName = "MadMcCrow";
    userEmail = "noe.perard+git@gmail.com";
    lfs.enable = true;
    extraConfig = {
      help.autocorrect = 10;
      color.ui = "auto";
      core.whitespace = "trailing-space,space-before-tab";
      apply.whitespace = "fix";
    };
  };

  # github cli tool
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
    extensions = with pkgs; [ gh-eco gh-cal gh-dash ];
    enableGitCredentialHelper = true;
  };

  # ZSH :
  programs.zsh = {
    enable = true ;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
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
    shellAliases = { code = "codium"; };
    enableSyntaxHighlighting = true;
  };

  # Bash And Zsh shell history suggest box
  programs.hstr.enable = true;

  programs.powerline-go = {
    enable = true;
    modules = [ "user" "host" "nix-shell" "cwd" "gitlite" "root" ];
    modulesRight = [ "exit" "time" ];
    settings = {
      hostname-only-if-ssh = true;
      numeric-exit-codes = true;
      cwd-max-depth = 3;
      git-mode = "compact";
      priority = [ "root" "cwd" "user" "nix-shell" "gitlite" ];
    };
  };

  # bash is used in nix-shell
  programs.bash = {
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

  # eza is ls but improved
  programs.exa = {
    enable = true;
    enableAliases = true;
    git = true;
    extraOptions = [ "--group-directories-first" "--header" ];
  };

  # environment switcher
  programs.direnv = {
    enable =true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
