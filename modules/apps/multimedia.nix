# apps/multimedia.nix
# 	the multimedia apps : vlc, mellowplayer, etc
{ config, pkgs }:
let cfg = config.apps.multimedia;
in {
  # interface
  options.apps.multimedia.enable = lib.mkOption {
    type = types.bool;
    default = true;
    description = "wether to have multimedia apps";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vlc # maybe gnome video would be better
      mellowplayer # allow deezer and spotify streaming
      chromium # for netflix, etc...
    ];

    # make sure chromium has widevine (L1 - SD support only)
    nixpkgs.config.chromium = { enableWideVine = true; };
  };
}

