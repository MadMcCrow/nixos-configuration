# gaming/steam.nix
#	Make steam works on your system
{ config, pkgs, lib, unfree, ... }:
with builtins;
let
  # stable steam installation :
  # environment.systemPackages = let
  # stable = import nixpkgs-unstable { allowUnfree = true; };
  # in 
  # [ stable.steam ];
  # config interface
  cfg = config.apps.steam;
  # TODO : add all of steamPackages
  mySteam = with pkgs; [steam steam-run steamcmd steamPackages.steam steamPackages.steam-runtime];
  steamUnfree = [ "steam" "steam-run" "steamcmd" "steam-original" "steam-runtime" ]; #map (p : (lib.getName p)) mySteam;
in {
  #interface
  options.apps.steam = {
    enable = lib.mkEnableOption (mdDoc "steam, the PC Gaming platform") // {
      default = true;
    };
  };
  # config
  config = lib.mkIf cfg.enable {
    apps.packages = mySteam ++ [pkgs.libglvnd];

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
    unfree.unfreePackages = steamUnfree;
  };
}

