# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{ pkgs, ... }:
let serverData = "/run/server_data";
in {

  networking.hostName = "terminus"; # "Terminus/Foundation";
  networking.domain = "foundation.ovh";

  nixos.zfs.enable = true;

  # our custom modules config :
  nixos.flatpak.enable = true;
  nixos.server.enable = true;

  nixos.gpu.vendor = "intel";
  nixos.server.containers.nextcloud.dataDir = "${serverData}/nextcloud";

  # drive for server databases (Postgre)
  fileSystems."${serverData}" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    neededForBoot = false;
    options = [ "compress=zstd" "noatime" ];
  };
  # scrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "${serverData}" ];
  };

  # Power Management : minimize consumption
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop = true;
    scsiLinkPolicy = "min_power";
  };

  # maybe consider adding swap ?
  swapDevices = [ ];
  system.stateVersion = "23.11";
}
