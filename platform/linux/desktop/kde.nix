# desktop/kde.nix
# 	KDE FOR DESKTOP
{ config, pkgs-latest, lib, ... }:
let
  # change to plasma6 when we upgrade to 24.05
  plasmaVersion = "5" ;
in
lib.mkIf config.nixos.desktop.enable {
  # set tag for version
  system.nixos.tags = [ "KDE" ];

  #
  services.xserver.enable = true;

  services.xserver.desktopManager."plasma${plasmaVersion}" = {
    enable = true;
    useQtScaling = true;
    bigscreen.enable = true;
  };
  # enable plasma
  qt.enable = true;
  qt.platformTheme = "kde";

  programs.dconf.enable = true;
  programs.kdeconnect.enable = true;
  programs.partition-manager.enable = true;

  environment."plasma${plasmaVersion}".excludePackages = with pkgs-latest.kdePackages;
    [
      oxygen
      khelpcenter
      plasma-browser-integration
      print-manager
      kio-extras
      khelpcenter
      kwallet
      kwallet-pam
      kate
    ] ++ (with pkgs-latest.libsForQt5; [ kemoticons ]);

  environment.systemPackages = with pkgs-latest; [ dconf dconf2nix lightly-qt ];
}
