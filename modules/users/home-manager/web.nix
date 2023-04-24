# home-manager/zsh.nix
#   a modern shell
{ pkgs, useFirefox ? true,  }:
{
  programs = {
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition-bin;
    };
  };
}