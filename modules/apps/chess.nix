# chess.nix
# 	Add gnome-chess to your system
{ config, pkgs, lib, impermanence, ... }:
with builtins;
with lib;
let cfg = config.apps.flatpak;
in {

  # interface
  options.apps.chess.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "Add a chess game to your system";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome.gnome-chess
      stockfish
      uchess
    ];
  };
}
