{ lib, pkgs, ... }:
{
  # enable HM
  programs.home-manager.enable = true;
  home.packages = (with pkgs; [
    powerline-go
    zsh-autosuggestions
    zsh-syntax-highlighting
    jetbrains-mono
    python3
    clang-tools_16
  ]);

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

  # environment switcher
  programs.direnv = {
    enable =true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}