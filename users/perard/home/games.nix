# desktop/games.nix
# 	helps play games in nixos
# TODO : add minecraft
# TODO : steam stable
{ pkgs, config, lib, ... }:
let

  # TODO : use stable !
  # stable-pkgs = pkgs;

  # Steam
  steamLibs = p:
    with p; [
      libglvnd
      libgdiplus
      libpng
      procps
      usbutils
      libcap
      # VR :
      openhmd
      openxr-loader
      pango
    ];

  steamPkgs = with pkgs;
    [
      steam
      steam-run
      steamcmd

    ] ++ steamLibs pkgs;

in {

  # config
  config = {

    # Packages
    home.packages = with pkgs;
      steamPkgs ++ [ minigalaxy ]; # ++ [ prismlauncher ];

    # env vars for steam and steam VR
    home.sessionVariables = {
      # STEAM_RUNTIME="1";
      # STEAM_RUNTIME_PREFER_HOST_LIBRARIES="0";
    };

    packages.unfree = [ "steam-original" "steam" "steam-run" "steamcmd" ];

    packages.overlays = [
      (self: super: {
        steam = super.steam.override { extraPkgs = steamLibs; };
      })
    ];
  };
}
