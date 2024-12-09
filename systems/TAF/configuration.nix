# TAF
#   previously "AF"
#   this is my main desktop PC
{ _ }:
{

  networking.hostName = "trantor"; # previously "nixAF"

  # options from this flake :
  nixos = {
    fileSystem = {
      enable = true;
      boot = "/dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489";
      luks = "/dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03";
      swap = true;
    };
    # enable desktop environment :
    desktop.enable = true;
    ## enable flatpak apps
    flatpak.enable = true;
    # faster start-up
    boot.sleep = true;
    boot.fastBoot = true;
    # gamepad, mouse, etc ...
    vendor = {
      logitech.enable = true;
      valve.enable = true;
      xbox.enable = true;
    };
    # open steam firewall for game hosting
    desktop.steam.firewall.enable = true;
  };

  # gaming :
  programs.gamemode = {
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
      gpu = {
        # apply_gpu_optimisations = "accept-responsibility";
        #gpu_device = 1;
        #amd_performance_level = "high";
      };
    };

    # Power Management :
    powerManagement.enable = true;
    powerManagement.cpuFreqGovernor = "performance";

    system.stateVersion = "24.05";
  };
}
