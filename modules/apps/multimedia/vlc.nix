# apps/multimedia.nix
# 	the multimedia apps : vlc, mellowplayer, etc
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  mma = config.apps.multimedia;
  cfg = mma.vlc;
in {
  # interface
  options.apps.multimedia.vlc.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "VLC media player";
  };
  # config
  config =
    lib.mkIf cfg.enable { environment.systemPackages = with pkgs; [ vlc ]; };
}

