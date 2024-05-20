# desktop/kde.nix
# 	Gamescope compositor for gaming on the desktop
{ config, lib, ... }:
let
  enable = config.nixos.desktop.enable
    && config.nixos.desktop.steamSession.enable;
in {

  # interface
  options.nixos.desktop.steamSession = {
    enable = lib.mkEnableOption "Steam gamescope session";
  };

  # implementation
  config = lib.mkIf enable {
    programs.gamescope.enable = true;
    programs.steam.gamescopeSession.enable = true;
    nixos.nix.unfreePackages = [ "steam" ];
  };
}
