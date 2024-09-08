# TAF
#   previously "AF"
#   this is my main desktop PC
{ ... }:
{

  networking.hostName = "trantor"; # previously "nixAF"

  # options from this flake :
  nixos = {
    # enable desktop environment :
    desktop.enable = true;
    ## enable flatpak apps
    flatpak.enable = true;
    # faster start-up
    boot.sleep = true;
    boot.fastBoot = true;
    # gamepad, mouse, etc ...
    vendor.logitech.enable = true;
    vendor.valve.enable = true;
    vendor.xbox.enable = true;
    # open steam firewall for game hosting
    desktop.steam.firewall.enable = true;
  };

  # gaming :
  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
    enableRenice = true;
  };

  # Power Management :
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  system.stateVersion = "23.11";
}
