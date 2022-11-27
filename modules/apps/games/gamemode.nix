# games/steam.nix
#	Make steam works on your system
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  gms = config.apps.games;
  cfg = gms.gamemode;
in {
  # interface
  options.apps.games.gamemode = {
    enable = mkOption {
      type = types.bool;
      default = gms.enable;
      description = ''
        GameMode is a daemon/lib combo for Linux that allows games
         to request a set of optimisations be temporarily applied 
         to the host OS and/or a game process. 
      '';
    };
  };
  # config
  config = mkIf cfg.enable {
    programs.gamemode.enable = true;
    programs.gamemode.settings.general.inhibit_screensaver = 0;
  };
}

