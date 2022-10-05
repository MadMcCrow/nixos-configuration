# pantheon.nix
# 	Nixos Pantheon Desktop environment settings
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.pantheon;

  extraApps = with pkgs;
    [
      elementary-code

    ];

in {

  # interface
  options.pantheon = {
    # do you want pantheon Desktop environment
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = "enable pantheon Desktop environment";
    };

    wayland = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Wayland is the new standard meant to replace Xorg";
    };

    # useful apps
    extraApps = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Some (useful) curated gnome apps";
    };

    # somewhat useful optional apps apps
    superExtraApps = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Some curated gnome apps that are fun but not useful";
    };

  };

  # base config for gnome 
  config = lib.mkIf cfg.enable {

    services.xserver = {
      # enable GUI
      enable = true;

      # remove xterm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;

      # GDM :
      displayManager = {
        gdm = {
          enable = true;
          wayland = cfg.wayland; # Wayland
        };
      };
      # use Gnome
      desktopManager.pantheon.enable = true;
    };
    programs.xwayland.enable = cfg.wayland;
    programs.pantheon-tweaks.enable = true;
  };
}
