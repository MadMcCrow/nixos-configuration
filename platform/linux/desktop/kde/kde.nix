# desktop/kde.nix
# 	KDE FOR DESKTOP
{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.nixos.desktop.enable {
  # set tag for version
  system.nixos.tags = [ "KDE" ];

  #
  services.xserver = {
    enable = true;

    # Enable Plasma 5 or 6
    desktopManager.plasma5 = {
      enable = true;
      useQtScaling = true;
      # default font with extra
      notoPackage = pkgs.noto-fonts-lgc-plus;
    };
    # remove xterm
    desktopManager.xterm.enable = false;
    excludePackages = [ pkgs.xterm ];

  };

  # enable plasma
  qt.enable = true;
  qt.platformTheme = "kde";

  # enable tools
  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;
    partition-manager.enable = true;
  };

  # remove useless KDE packages
  environment.plasma5.excludePackages =
    with pkgs.libsForQt5;
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
    ]
    ++ (with pkgs.libsForQt5; [ kemoticons ]);

  environment.systemPackages = with pkgs; [
    lightly-boehs
    (callPackage ./vapor-theme.nix { })
    # (callPackage ./plasma-drawer.nix { })
    papirus-icon-theme
    libsForQt5.kcalc
  ];

}
