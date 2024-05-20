# Server specific options for NUC
{ pkgs, ... }:
let serverDataDir = "/run/server_data";
in {
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

  # STORAGE :
  # BTRFS drive for server container and services :
  fileSystems."${serverDataDir}" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    neededForBoot = false;
    options = [ "compress=zstd" "noatime" ];
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "daily";
    fileSystems = [ "${serverDataDir}" ];
  };
}
