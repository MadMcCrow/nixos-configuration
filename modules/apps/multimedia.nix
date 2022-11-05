# apps/multimedia.nix
# 	the multimedia apps : vlc, mellowplayer, etc
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let cfg = config.apps.multimedia;
in {

  imports = [ ../unfree.nix ];

  # interface
  options.apps.multimedia.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "wether to have multimedia apps";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vlc # maybe gnome video would be better
      mellowplayer # allow deezer and spotify streaming
      chromium # for netflix, etc...
      pitivi # video editor
    ];

    # make sure chromium has widevine (L1 - SD support only)
    nixpkgs.config.chromium = { enableWideVine = true; };

    unfree.unfreePackages = [ "chromium" ];

  };
}

