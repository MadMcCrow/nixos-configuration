# desktop.nix
#
#
{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.desktop = with lib; {
    enable = mkEnableOption "desktop experience";
  };

  config = lib.mkMerge [
    (lib.attrsets.optionalAttrs config.desktop.enable {

      services = {
        displayManager.sddm = {
          enable = true;
          enableHidpi = true;
          autoNumlock = true;
          # this prevents issues with nvidia drivers
          wayland.enable =
            !(builtins.any (
              x: x == "nvidia"
            ) config.services.xserver.videoDrivers);
        };
      };

      # set tag for version
      system.nixos.tags = [ "Desktop" ];

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
        plasma5.excludePackages =
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

        systemPackages =
          with pkgs;
          [
            lightly-boehs
            papirus-icon-theme
            libsForQt5.kcalc
          ]
          ++ map callPackage [
            ./packages/vapor-theme.nix
            # ./packages/plasma-drawer.nix
            # ./packages/ditto-menu.nix
          ];
      };
    })
    (lib.attrsets.optionalAttrs (!config.desktop.enable) {
      system.nixos.tags = [ "Headless" ];
      services.xserver.enable = false;

      services.kmscon = {
        enable = true;
        fonts = [
          {
            name = "Source Code Pro";
            package = pkgs.source-code-pro;
          }
          {
            name = "nerdfont";
            package = pkgs.nerdfonts;
          }
        ];
      };
    })
  ];
}
