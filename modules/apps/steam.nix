# gaming/steam.nix
#	Make steam works on your system
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  # config interface
  cfg = config.apps.steam;
in {
  #interface
  options.apps.steam = {
    enable = mkEnableOption (mdDoc "steam, the PC Gaming platform") // {
      default = true;
    };
  };
  # config
  config = mkIf cfg.enable {
    hardware.steam-hardware.enable = true; # Steam udev rules
    # steam 
    programs.steam = {
      enable = true;
      # Open ports in the firewall for Steam Remote Play and Source Dedicated Server
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # gamemode is usefull for playing games
    programs.gamemode = {
      enable = true;
      settings.general.inhibit_screensaver = 0;
    };

    # unfree packages
    unfree.unfreePackages =
      [ "steam" "steam-original" "steam-runtime" "steam-run" ];
  };
}

