# chess.nix
# 	Add gnome-chess to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  gms = config.apps.games;
  cfg = gms.chess;
in {

  # interface
  options.apps.games.chess.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Add a chess game to your system";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome.gnome-chess
      stockfish
      uchess
    ];
  };
}
