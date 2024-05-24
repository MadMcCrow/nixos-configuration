# Server specific options for NUC
{ pkgs, ... }:
let serverDataDir = "/var/www";
in {
  # SERVER :
  nixos.server = {
    enable = true;

    # bought and paid for !
    domainName = "asimov.ovh";

    # email for certificates and notifications
    adminEmail = "noe.perard+serveradmin@gmail.com";

    # DOCKER IMAGES :
    ## Home Assistant :
    containers.home-assistant.enable = false;
    containers.home-assistant.dataDir = "${serverDataDir}/homeassistant";

    # NIXOS SERVICES :
    # nextcloud cloud storage :
    services.nextcloud.enable = false;
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
    neededForBoot = true;
    options = [ "compress=zstd" "noatime" ];
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "${serverDataDir}" ];
  };
}
