# apps/multimedia.nix
# 	the multimedia apps : vlc, mellowplayer, etc
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let cfg = config.apps.multimedia;
in {

  # interface
  options.apps.multimedia.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "wether to have multimedia apps";
  };
  # imports
  imports = [ ./mellowplayer.nix ./vlc.nix ];
}

