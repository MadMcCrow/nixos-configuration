# desktop.nix
# add a desktop environment to our Config
#
{ config, pkgs, self, ... }: {

  # interface
  options.nonOS.desktop.enable = mkDisableOption "desktop";

  # implementation
  config = {

    # set tag for version
    system.nixos.tags = [ "Desktop" ];

    # enable sddm display manager
    services.displayManager.sddm = {
        enable = true;
        enableHidpi = true;
        autoNumlock = true;
        # this prevents issues with nvidia drivers
        wayland.enable = !(builtins.any (x: x == "nvidia")
          config.services.xserver.videoDrivers);
      };
    # enable KDE :
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
    qt = {
      enable = true;
      platformTheme = "kde";
    };

    # enable tools
    programs = {
      dconf.enable = true;
      kdeconnect.enable = true;
      partition-manager.enable = true;
    };

    # remove useless KDE packages
    environment = {
      plasma5.excludePackages = with pkgs.libsForQt5;
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

      systemPackages = with pkgs;
        [ lightly-boehs papirus-icon-theme libsForQt5.kcalc ]
        ++ (map (x: callPackage (self + "/packages/plasma/${x}") {}) [
          "vapor-theme.nix"
          # ./packages/plasma-drawer.nix
          # ./packages/ditto-menu.nix
        ]);
    };
  };
}
