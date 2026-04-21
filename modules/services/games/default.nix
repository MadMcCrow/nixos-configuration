# games.nix
# necessary module to play games on nixos
{ lib, config, ... }:
let cfg = config.nonOS.games;
in {
  # interface :
  options.nonOS.games = with lib; { enable = mkEnableOption "Games support"; };

  imports = [
  #  ./gog.nix
  #  ./hardware.nix
  #  ./steam.nix
  ];

  config = lib.mkIf cfg.enable {
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
      steam.extest = { inherit (cfg.valve) enable; };
    };
  };
}
