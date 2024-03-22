# home.nix
# home manager configuration for user
{ config, pkgs, lib, ... }: {

  # add our dconf settings
  imports = [
    ./dconf.nix
    ./deezer.nix
    ./discord.nix
    ./shared.nix
    ./games.nix
    ./wallpaper.nix
  ];

  config = {
    home.username = "perard";
    home.homeDirectory = "/home/perard";
    home.stateVersion = "23.11";

    # packages to install to profile
    home.packages = with pkgs; [
      dconf
      eza
      speechd
      bitwarden
      nss_latest
      openscad
      solvespace
      #blender <- this often breaks !
    ];

    # FIREFOX
    programs.firefox = import ./firefox.nix { inherit pkgs lib; };

    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
    };

  };

}
