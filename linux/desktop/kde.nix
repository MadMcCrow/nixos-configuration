# desktop/kde.nix
# 	KDE FOR DESKTOP
#   WIP !!!
{ config, pkgs, lib, ... }: {

  # base config for kde
  config = mkIf config.nixos.desktop.enable {

    system.nixos.tags = [ "KDE" ];

    services.xserver = {
      # enable GUI
      enable = true;

      # enable plasma
      desktopManager.plasma5 = {
        enable = true;
        useQtScaling = true;
      };

      # remove xterm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
      displayManager.defaultSession = "plasmawayland";
    };

    qt.enable = true;
    qt.platformTheme = "kde";

    programs.dconf.enable = true;
    programs.kdeconnect.enable = true;
    programs.partition-manager.enable = true;

    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
      oxygen
      khelpcenter
      plasma-browser-integration
      print-manager
      kio-extras
      ark
      elisa
      khelpcenter
      kemoticons
      kwallet
      kwallet-pam
    ];

    environment.systemPackages = with pkgs; [ dconf dconf2nix lightly-qt ];
  };
}
