# Server specific options for NUC
{ pkgs, ... }:
let serverDataDir = "/run/server_data";
in {
  # SERVER :
  nixos.server = {
    # email for certificates and notifications
    adminEmail = "noe.perard+serveradmin@gmail.com";

    # DOCKER IMAGES :
    containers.adguard.enable = true;
    containers.adguard.dataDir = "${serverDataDir}/adguard";
    # containers.home-assistant.enable = true;
    # containers.home-assistant.dataDir = "${serverDataDir}/homeassistant";

    # NIXOS SERVICES :

    # nextcloud cloud storage :
    services.nextcloud.enable = true;
    services.nextcloud.dataDir = "${serverDataDir}/nextcloud";
    # adguard DNS/adblocker :
    # services.adguard.enable = true;
    # services.adguard.dataDir = "${serverDataDir}/adguard";
  };

  # STORAGE :
  # BTRFS drive for server container and services :
  fileSystems."${serverDataDir}" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "compress=zstd" "noatime" ];
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "${serverDataDir}" ];
  };
}
