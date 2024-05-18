# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{ pkgs, ... }:
let
serverDataDir = "/run/server_data";
in {

  networking.hostName = "terminus"; # "Terminus/Foundation";
  networking.domain = "foundation.ovh";

  # HARDWARE :
  nixos.zfs.enable = true;
  nixos.gpu.vendor = "intel";

  # Power Management : minimize consumption
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
    scsiLinkPolicy = "min_power";
  };

  # Use kmscon as the virtual console :
  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [ { name = "Source Code Pro"; package = pkgs.source-code-pro; } ];
    extraOptions = "--term xterm-256color";
  };

  # maybe consider adding swap ?
  swapDevices = [ ];
  system.stateVersion = "23.11";
}
