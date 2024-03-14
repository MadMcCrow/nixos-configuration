# darwin.nix
# home manager configuration for MacOS
# TODO : browser
{ config, pkgs, ... }: {
  home.username = "perard";
  home.homeDirectory = "/Users/perard";
  home.stateVersion = "23.05";

  imports = [ ./shared.nix ];

  # environment switcher
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
