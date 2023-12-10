# environments/kde.nix
# 	Nixos Kde Desktop environment settings
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  dsk = config.nixos.desktop;
  cfg = dsk.kde;
  fpk = dsk.apps.flatpak.enable;
  wayland = dsk.displayManager.wayland.enable;

  # extra kde apps
  kdePkgs = pkgs.libsForQt5;
  extraApps = with kdePkgs; [ ];

  # some nice themes
  themes = with pkgs; [ lightly-qt ];

  # KDE/breeze for light-dm
  breeze-icons = {
    name = "Breeze";
    package = kdePkgs.breeze-icons;
  };
  breeze-gtk = {
    name = "Breeze-Dark";
    package = kdePkgs.breeze-gtk;
  };
  breeze-cursor = {
    name = "Breeze";
    package = kdePkgs.breeze-icons;
  };
  noto-font = {
    name = "Noto Sans";
    package = pkgs.noto-fonts;
  };

  # helper functions
  mkBoolOption = desc: default: (mkEnableOption desc) // { inherit default; };
  mkEnumOption = desc: list:
    mkOption {
      description = (concatStringsSep "," [ desc "one of " (toString list) ]);
      type = types.enum list;
      default = elemAt list 0;
    };

in {
  # interface
  options.nixos.desktop.kde = {
    # do you want gnome Desktop environment
    enable = mkBoolOption "KDE, the QT based desktop environment" false;
    # useful kde apps
    extraApps = mkBoolOption "Some (useful) curated kde apps" true;
    # theming
    themes = mkBoolOption "kde themes" true;
    # KDE connect
    kdeconnect = mkBoolOption "KDE connect service" true;
  };

  # base config for kde
  config = mkIf (dsk.enable && cfg.enable) {

    # force gtk to use breeze
    nixos.desktop = {
      gtk = {
        theme = breeze-gtk;
        iconTheme = breeze-icons;
        cursorTheme = breeze-cursor;
      };
      displayManager.type = "lightdm"; # lightdm is faster than sddm
    };

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
      displayManager.defaultSession =
        if wayland then "plasmawayland" else "plasma";
    };

    qt = {
      enable = true;
      platformTheme = "kde";
    };

    programs = {
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
        kio-extras
        ark
        elisa
        # gwenview
        # okular
        khelpcenter
        kemoticons
        kwallet
        kwallet-pam
      ];
      systemPackages = [ pkgs.dconf pkgs.dconf2nix ]
        ++ (if cfg.extraApps then extraApps else [ ])
        ++ (if cfg.themes then themes else [ ]);
    };
  };
}
