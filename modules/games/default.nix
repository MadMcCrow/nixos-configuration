# games.nix
# necessary module to play games on nixos
{ lib, config, ... }:
let
  cfg = config.games;
  mkDisableOption = d: mkEnableOption d // { default = true; };
in
{
  # interface :
  options.games = with lib; {
    enable = mkDisableOption "game support on nixos";
    xbox.enable = mkDisableOption "xbox hardware (controller, dongle, ...)";
    valve = {
      enable = mkEnableOption "steam, the video game service";
      firewall.enable = mkDisableOption "open firewall for steam games";
    };
  };
  # merge all options :
  config = lib.mkIf cfg.enable {
    hardware = {
      xone = {
        inherit (cfg.xbox) enable;
      };
      steam-hardware = {
        inherit (cfg.valve) enable;
      }; # Steam udev rules
    };

    nixos.nix.unfreePackages =
      with lib.lists;
      (optional cfg.valve.enable "steam-original")
      ++ (optional cfg.xbox.enable "xow_dongle-firmware");

    networking.firewall = lib.mkIf cfg.valve.enable {
      allowedTCPPorts = [
        27015 # remote play
        27036 # SRCDS Rcon port
      ];
      allowedUDPPorts = [ 27015 ]; # Gameplay traffic
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27036;
        }
      ]; # remote play
    };

    # 
    programs = {
      # gamemode improves performances
      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          custom = {
            start = "notify-send 'GameMode started'";
            end = "notify-send 'GameMode ended'";
          };
          general = {
            inhibit_screensaver = 0;
            desiredgov = "performance";
            renice = 10;
          };
          # test before changing
          #gpu = {
          # apply_gpu_optimisations = "accept-responsibility";
          #gpu_device = 1;
          #amd_performance_level = "high";
          # };
        };
      };
      # Reimplementation for Steam Controller on Wayland
      steam.extest = {
        inherit (cfg.valve) enable;
      };
    };
  };
}
