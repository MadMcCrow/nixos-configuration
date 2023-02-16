# kde.nix
# 	Nixos Kde Desktop environment settings
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  dsk = config.desktop;
  cfg = dsk.kde;

  # extra kde apps
  extraApps = with pkgs.libsForQt5; [ ];

  # some nice themes
  themes = with pkgs; [ kde-gruvbox kde-rounded-corners ];

in {

  # interface
  options.desktop.kde = {
    # do you want gnome Desktop environment
    enable = mkEnableOption (mdDoc "KDE, the QT based desktop environment");

    wayland = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Wayland is the new standard meant to replace Xorg";
    };

    sddm = lib.mkOption {
      type = types.bool;
      default = true;
      description = "use sddm as a greeter";
    };

    # useful kde apps
    extraApps = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Some (useful) curated kde apps";
    };

    # theming
    themes = lib.mkOption {
      type = types.bool;
      default = true;
      description = "add kde themes";
    };

    # KDE connect
    kdeconnect = lib.mkOption {
      type = types.bool;
      default = true;
      description =
        "KDE connect allows having a connection between your devices";
    };
  };

  # base config for kde 
  config = lib.mkIf (dsk.enable && cfg.enable) {

    services.xserver = {
      # enable GUI
      enable = true;

      # enable plasma
      desktopManager.plasma5 = {
        enable = true;
        # remove useless apps
        excludePackages = with pkgs.libsForQt5; [
          oxygen
          khelpcenter
          plasma-browser-integration
          print-manager
        ];

        # enable HiDpi
        useQtScaling = true;
        # brightness control
        supportDDC = true;
      };

      # remove xterm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;

      # sddm :
      displayManager = {
        sddm = {
          enable = cfg.sddm;
          # wayland = cfg.wayland;  # option does not exist
        };
      };
    };

    # QT settings
    qt = {
      enable = true;
      platformTheme = "kde";
    };

    # enable xwayland
    programs = {
      # support wayland
      xwayland.enable = cfg.wayland;
      # support gnome apps
      dconf.enable = true;
      # KDE Connect
      kdeconnect.enable = cfg.kdeconnect;
      partition-manager.enable = cfg.extraApps;
    };

    # packages
    environment.systemPackages = [ pkgs.dconf pkgs.dconf2nix ]
      ++ (if cfg.extraApps then extraApps else [ ])
      ++ (if cfg.themes then themes else [ ]);

  };
}
