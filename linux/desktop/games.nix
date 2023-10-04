# desktop/games.nix
# 	helps play games in nixos
# TODO : Add GameScope to have steamdeck ui and compositor for better framerate
# TODO : add pufferpanel for server (helps set dedicated servers)
# TODO : add minecraft
# TODO : steam stable
{ pkgs, config, lib, nixpkgs-stable, ... }:
with builtins;
with lib;
let

  # not working (will not work with AllowUnfreePredicate )
  # stable pkgs for packages being broken on instable (like steam)
  #stable-pkgs = nixpkgs-stable.legacyPackages.${pkgs.system};
  stable-pkgs = pkgs;

  # shortcut :
  nos = config.nixos;
  dsk = nos.desktop;
  cfg = dsk.games;
  # helper option function
  mkEnableOptionDefault = desc: default:
    (mkEnableOption desc) // {
      inherit default;
    };

  condList = c: l: if c then l else [ ];

  # vr libs :  openhmd openxr-loader pango
  # Steam VR
  steamlibs = pkgs : with pkgs; [ libglvnd libgdiplus libpng procps usbutils libcap];

in {
  # interface
  options.nixos.desktop.games = {
    enable = mkEnableOptionDefault "gaming on nixos" false;
    logitech.enable = mkEnableOptionDefault "logitech software" false;
    xone.enable = mkEnableOptionDefault "XBox One driver" true;
    steam.enable = mkEnableOptionDefault "Steam" true;
    gog.enable = mkEnableOptionDefault "Good Old Games" true;
    # minecraft is broken : launcher fails to download files : either use flatpak or prismlauncher
    minecraft.enable = mkEnableOptionDefault "Minecraft" false;
  };

  # config
  config = mkIf cfg.enable {
    # drivers
    hardware = {
      xone.enable = cfg.xone.enable;
      firmware = condList cfg.xone.enable [ pkgs.xow_dongle-firmware ];
      logitech.wireless = {
        enable = cfg.logitech.enable;
        enableGraphical = true;
      };
      steam-hardware.enable = cfg.steam.enable; # Steam udev rules
    };

    programs.gamemode = {
      enable = cfg.enable;
      settings.general.inhibit_screensaver = 0;
      enableRenice = true;
    };

    programs.steam = mkIf cfg.steam.enable {
      # uses stable instead of latest
      package = stable-pkgs.steam;
      enable = cfg.steam.enable;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # Packages
    environment.systemPackages = with pkgs;
      concatLists [
      (condList cfg.logitech.enable [ logitech-udev-rules solaar ])
      (condList cfg.xone.enable [ xow_dongle-firmware config.boot.kernelPackages.xone])
      (condList cfg.steam.enable [ steam steam-run steamcmd ] ++ (steamlibs pkgs))
      (condList cfg.gog.enable [ minigalaxy ])
      (condList cfg.minecraft.enable [prismlauncher])
      ];

    # env vars for steam and steam VR
    #environment.variables = {
    #  # STEAM_RUNTIME="1";
    #  STEAM_RUNTIME_PREFER_HOST_LIBRARIES="0";
    #  };

    packages.unfreePackages = concatLists [
      (condList cfg.xone.enable [ "xow_dongle-firmware" ])
      (condList cfg.steam.enable [
        "steam-original"
        "steam"
        "steam-run"
        "steamcmd"
      ])
      (condList cfg.minecraft.enable [])];

    packages.overlays = condList cfg.steam.enable [
      (self: super: {
        steam = super.steam.override {
          extraPkgs = steamlibs;
        };
      })
    ];
  };
}
