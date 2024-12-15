# games.nix
# 	helps play games in nixos
# TODO : add minecraft
# TODO : steam stable
{
  pkgs,
  config,
  lib,
  ...
}:
let
  # Extest is a drop in replacement for the X11 XTEST extension. It creates a virtual device with the uinput kernel module.
  # It's been primarily developed for allowing the desktop functionality on the Steam Controller to work while Steam is open on Wayland.
  # this needs to be built as a 32 bit library
  extest = pkgs.rustPlatform.buildRustPackage rec {
    pname = "extest";
    version = "1.0.2";
    src = pkgs.fetchFromGitHub {
      repo = "extest";
      owner = "Supreeeme";
      rev = version;
      hash = "sha256-qdTF4n3uhkl3WFT+7bAlwCjxBx3ggTN6i3WzFg+8Jrw=";
    };
    cargoLock.lockFile = "${src}/Cargo.lock";
    meta = {
      homepage = "https://github.com/Supreeeme/extest";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };

  # Steam
  steamLibs =
    p: with p; [
      gamescope
      mangohud
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

  steamPkgs =
    with pkgs;
    [
      steam
      steam-run
      steamcmd
      gamescope
    ]
    ++ steamLibs pkgs;

in
{

  # config
  config = {

    # Packages
    home.packages = with pkgs; [ minigalaxy ] ++ steamPkgs ++ [ extest ]; # ++ [ prismlauncher ];

    # env vars for steam and steam VR
    home.sessionVariables = {
      # STEAM_RUNTIME="1";
      # STEAM_RUNTIME_PREFER_HOST_LIBRARIES="0";
    };

    packages.unfree = [
      "steam-original"
      "steam"
      "steam-run"
      "steamcmd"
    ];

    packages.overlays = [
      (_: super: {
        steam = super.steam.override {
          extraPkgs = steamLibs;
          #extraProfile =
          #  "export LD_PRELOAD=${extest}/lib/libextest.so:$LD_PRELOAD";
        };
      })
    ];
  };
}
