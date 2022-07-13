# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
 imports = [<home-manager/nixos> ];
  
  # home manager
  
  # Users
  users.mutableUsers = false;
  # perard
  users.users.perard = {
     isNormalUser = true;
     extraGroups = [ "wheel" "flatpak"];
    initialHashedPassword = "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
  };
  home-manager.users.perard = { pkgs, ... }: {
  home.packages = with pkgs; [
       firefox
       chromium
       vlc
       gnomeExtensions.tilingnome
       gnomeExtensions.pop-shell
       gnome.gnome-tweaks
    ];
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;
  };
  
  
    users.users.desrumaux = {
    isNormalUser = true;
    extraGroups = ["flatpak"];
    initialHashedPassword = "$6$/bQNXdEm.9DwhO/2$EsUPTNdhCLuUW3pdq5IncbGUaOKDo0WgYvMB6JeReoyvroTX0mV3VaM1t4kHMuqLL/.3WAAWOEm8Ut9VlJUGz.";
  };
  home-manager.users.desrumaux = { pkgs, ... }: {
  home.packages = with pkgs; [
       chromium
    ];
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;
  };
}
