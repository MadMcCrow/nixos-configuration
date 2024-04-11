# kde.nix
# 	Nixos Kde Desktop environment settings
{ config, pkgs, lib, ... }:
lib.mkIf config.nixos.tv.enable {

  services.xserver.enable = true;

  services.xserver.desktopManager.plasma5 = {
    enable = true;
    useQtScaling = true;
    bigscreen.enable = true;
  };

  # services.xserver.displayManager.defaultSession = "plasmawayland";

  qt.enable = true;
  qt.platformTheme = "kde";

  programs.dconf.enable = true;
  programs.kdeconnect.enable = false;

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

  environment.systemPackages = with pkgs; [
    libsForQt5.plasma-bigscreen
    lightly-qt
  ];
}
