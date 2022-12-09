# kde.nix
# 	Nixos Kde Desktop environment settings
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.desktop.kde;

  # extra kde apps
  extraApps = with pkgs.libsForQt5; [ ];
 
  # some nice themes
  themes = with pkgs; [kde-gruvbox kde-rounded-corners];

in {

  # interface
  options.desktop.kde = {
    # do you want gnome Desktop environment
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = "enable kde Desktop environment";
    };

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
      description = "add gnome/gtk themes";
    };

    # KDE connect
    # todo : allow enabling without kde
    kdeconnect = lib.mkOption {
      type = types.bool;
      default = true;
      description = "KDE connect allows having a connection between your devices";
    };
  };

  # base config for kde 
  config = lib.mkIf cfg.enable {

    services.xserver = {
      # enable GUI
      enable = true;

      # enable plasma
      desktopManager.plasma5.enable = true;

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

    # enable xwayland
    programs.xwayland.enable = cfg.wayland;
    # support gnome apps
    programs.dconf.enable = true;

    # packages
    environment.systemPackages = [ pkgs.dconf pkgs.dconf2nix ]
      ++ (if cfg.extraApps then extraApps else [ ])
      ++ (if cfg.themes then themes else [ ]);
  };
}
