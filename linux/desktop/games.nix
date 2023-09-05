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

  # not working (cannot find inputs)
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

in {
  # interface
  options.nixos.desktop.games = {
    enable = mkEnableOptionDefault "gaming on nixos" false;
    logitech.enable = mkEnableOptionDefault "logitech software" false;
    xone.enable = mkEnableOptionDefault "XBox One driver" true;
    steam.enable = mkEnableOptionDefault "Steam" true;
    gog.enable = mkEnableOptionDefault "Good Old Games" true;
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
      (condList cfg.steam.enable [ steam steam-run steamcmd libglvn openhmd libgdiplus libpng])
      (condList cfg.gog.enable [ minigalaxy ])
      ];

    packages.unfreePackages = concatLists [s
      (condList cfg.xone.enable [ "xow_dongle-firmware" ])
      (condList cfg.steam.enable [
        "steam-original"
        "steam"
        "steam-run"
        "steamcmd"
      ])];

    packages.overlays = condList cfg.steam.enable [
      (self: super: {
        steam = super.steam.override {
          extraPkgs = pkgs: [ pkgs.libgdiplus pkgs.libpng pkgs.openhmd ];
        };
      })
    ];
  };
}
