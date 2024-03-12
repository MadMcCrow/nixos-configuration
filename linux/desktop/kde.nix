# desktop/kde.nix
# 	KDE FOR DESKTOP
{ config, pkgs, lib, ... }:
lib.mkIf config.nixos.desktop.enable {

    system.nixos.tags = [ "KDE" ];

    services.xserver.enable = true;

     # enable plasma
    services.xserver.desktopManager.plasma6.enable = true;
    qt.enable = true;
    qt.platformTheme = "kde";

    programs.dconf.enable = true;
    programs.kdeconnect.enable = true;
    programs.partition-manager.enable = true;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      oxygen
      khelpcenter
      plasma-browser-integration
      print-manager
      kio-extras
      elisa
      khelpcenter
      kwallet
      kwallet-pam
      kate
    ]
    ++ (with pkgs.libsForQt5; [kemoticons]);

    environment.systemPackages = with pkgs; [ dconf dconf2nix lightly-qt ];
  }
