# linux.nix
# linux user configuration
{ config, pkgs, lib, pkgs-latest, ... }@args: {
  # import modules
  imports = [
    ./applications # TODO : make a module with options :
    ./git.nix
    ./shell.nix
    ./wallpaper.nix
    # we need this module to work
    ./nixpkgs.nix
  ];
  # home setup
  config = {
    home.username = "perard";
    home.homeDirectory = "/home/perard";
    home.stateVersion = "23.11";

    xdg.mimeApps.enable = true;

    # packages to install to profile
    home.packages = with pkgs-latest; [
      jetbrains-mono
      python3
      speechd
      bitwarden
    ];
    # gpg key management (linux only)
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
