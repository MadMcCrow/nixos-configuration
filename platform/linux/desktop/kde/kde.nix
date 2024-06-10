# desktop/kde.nix
# 	KDE FOR DESKTOP
{ config, pkgs, pkgs-latest, lib, ... }:

lib.mkIf config.nixos.desktop.enable {
  # set tag for version
  system.nixos.tags = [ "KDE" ];

  #
  services.xserver.enable = true;

  # Enable Plasma 5 or 6
  services.xserver.desktopManager.plasma5 = {
    enable = true;
    useQtScaling = true;
    # default font with extra
    notoPackage = pkgs-latest.noto-fonts-lgc-plus;
  };

  # enable plasma
  qt.enable = true;
  qt.platformTheme = "kde";

  # enable tools
  programs.dconf.enable = true;
  programs.kdeconnect.enable = true;
  programs.partition-manager.enable = true;

  # remove xterm
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.excludePackages = [ pkgs.xterm ];
  # remove useless KDE packages
  environment.plasma5.excludePackages = with pkgs.libsForQt5;
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
      okular
    ] ++ (with pkgs.libsForQt5; [ kemoticons ]);

  environment.systemPackages = with pkgs; [
    lightly-boehs
    (callPackage ./vapor-theme.nix { })
    # (callPackage ./plasma-drawer.nix { })
    papirus-icon-theme
    libsForQt5.kcalc
  ];

}
