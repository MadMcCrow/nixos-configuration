# kde.nix
# 	Nixos Kde Desktop environment settings
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  dsk = config.nixos.desktop;
  cfg = dsk.kde;

  # extra kde apps
  kdePkgs = pkgs.libsForQt5;
  extraApps = with kdePkgs; [ ];

  # some nice themes
  themes = with pkgs; [
    lightly-qt
    kde-gruvbox
    kde-rounded-corners
    colloid-kde
    catppuccin-kde
    nordic
  ];

  # KDE/breeze for light-dm
  breeze-icons = { name = "Breeze";    package = kdePkgs.breeze-icons; };
  breeze-gtk   = { name = "Breeze";    package = kdePkgs.breeze-gtk;   };
  noto-font    = { name = "Noto Sans"; package = pkgs.noto-fonts;      };

  lightdm-greeter-theme =  {
    cursorTheme = breeze-icons;
    iconTheme = breeze-icons;
    #font = noto-font;
    theme = breeze-gtk;
  };



  # helper functions
  mkBoolOption = desc: default:
    mkEnableOption (mdDoc desc) // {
      inherit default;
    };
  mkEnumOption = desc: list:
    mkOption {
      description =
        mdDoc (concatStringsSep "," [ desc "one of " (toString list) ]);
      type = types.enum list;
      default = elemAt list 0;
    };

in {
  # interface
  options.nixos.desktop.kde = {
    # do you want gnome Desktop environment
    enable = mkBoolOption "KDE, the QT based desktop environment" false;
    # wayland support
    wayland =
      mkBoolOption "Wayland is the new standard meant to replace Xorg" true;
    # login manager
    displayManager =
      mkEnumOption "display (login) manager to use" ([ "sddm" "lightdm" ]);
    # useful kde apps
    extraApps = mkBoolOption "Some (useful) curated kde apps" true;
    # theming
    themes = mkBoolOption "kde themes" true;
    # KDE connect
    kdeconnect = mkBoolOption "KDE connect service" true;
  };

  # base config for kde 
  config = mkIf (dsk.enable && cfg.enable) {

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

      # sddm :
      displayManager = let dm = cfg.displayManager;
      in {
        # default to wayland if pog != dssible
        defaultSession = if cfg.wayland then "plasmawayland" else "plasma";
        # sddm config
        sddm.enable = dm == "sddm";
        # light dm config
        lightdm = {
          enable = true;
          #greeter.package = pkgs.lightdm-slick-greeter;
          #greeters.slick = lightdm-greeter-theme // { enable = true;};
          greeters.gtk = lightdm-greeter-theme;
        };
      };
    };

    qt = {
      enable = true;
      platformTheme = "kde";
    };

    programs = {
      xwayland.enable = cfg.wayland;
      dconf.enable = true;
      kdeconnect.enable = cfg.kdeconnect;
      partition-manager.enable = cfg.extraApps;
    };

    environment = {
      plasma5.excludePackages = with kdePkgs; [
        oxygen
        khelpcenter
        plasma-browser-integration
        print-manager
      ];
      systemPackages = [ pkgs.dconf pkgs.dconf2nix ]
        ++ (if cfg.extraApps then extraApps else [ ])
        ++ (if cfg.themes then themes else [ ]);
    };
  };
}
