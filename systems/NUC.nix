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

  # SERVER :
  nixos.server = {
    # email for certificates and notifications
    adminEmail = "noe.perard+serveradmin@gmail.com";

    # DOCKER IMAGES : :
    # containers.home-assistant.enable = true;
    # containers.home-assistant.dataDir = "/run/server/homeassistant";

    # NIXOS SERVICES :

    # nextcloud cloud storage :
    services.nextcloud.enable = true;
    services.nextcloud.dataDir = "${serverDataDir}/nextcloud";
    # adguard DNS/adblocker :
    services.adguard.enable = true;
    services.adguard.dataDir = "${serverDataDir}/adguard";
  };

  # drive for server container and services :
  fileSystems."${serverDataDir}" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    neededForBoot = false;
    options = [ "compress=zstd" "noatime" ];
  };
  # scrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "daily";
    fileSystems = [ "${serverDataDir}" ];
  };

  # Power Management : minimize consumption
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
    scsiLinkPolicy = "min_power";
  };


  # maybe consider adding swap ?
  swapDevices = [ ];
  system.stateVersion = "23.11";
}
