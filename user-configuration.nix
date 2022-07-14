# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];

  # Users
  users.mutableUsers = false;
  # perard
  users.users.perard = {
    description = "Noé Perard-Gayot";
    isNormalUser = true;
    extraGroups = [ "wheel" "flatpak" "steam"];
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
    home = "/home/perard";
    homeMode = "700";
    uid = 1000;
    shell = pkgs.zsh;
  };
  home-manager.users.perard = { lib, pkgs, ... }: {
    home = {
      packages = with pkgs; [
        zsh-powerlevel10k
        firefox
        chromium
        vlc
        gnome.gnome-tweaks
        gnomeExtensions.pop-shell
        gnomeExtensions.pop-launcher-super-key
        gnomeExtensions.caffeine
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock-for-cosmic
        gnomeExtensions.dash-to-dock
      ];
      stateVersion = "22.05";
    };
    programs = {
      home-manager.enable = true;
      git = {
        enable = true;
        userName = "MadMcCrow";
        lfs.enable = true;
      };
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = ["git"];
          theme = "robbyrussell";
        };
        plugins = [{
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }];
      };
    };
  };

  # guest
  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "guests" ];
    home = "/home/guest";
    homeMode = "764";
    uid = 1001;
  };
}
