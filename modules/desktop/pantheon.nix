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

    # useful apps
    extraApps = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Some (useful) curated elementary apps";
    };

    # somewhat useful optional apps
    superExtraApps = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Some curated elementary apps that are fun but not useful";
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
      displayManager = { lightdm = { enable = true; }; };
      # use pantheon
      desktopManager.pantheon.enable = true;
    };
    programs.pantheon-tweaks.enable = true;
  };
}
