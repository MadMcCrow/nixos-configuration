# apps/multimedia.nix
# 	the multimedia apps : vlc, mellowplayer, etc
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  mma = config.apps.multimedia;
  cfg = mma.mellowPlayer.enable;
in {
  # interface
  options.apps.multimedia.mellowPlayer.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "mellowPlayer allows deezer and spotify streaming";
  };
  # config
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ mellowplayer ];
  };
}

