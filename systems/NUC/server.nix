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
    containers.home-assistant.enable = true;
    containers.home-assistant.subDomain = "irobot"; # I Robot
    containers.home-assistant.dataDir = "${serverDataDir}/homeassistant";

    # NIXOS SERVICES :
    # nextcloud cloud storage :
    services.nextcloud.enable = true;
    services.nextcloud.subDomain = "foundation";
    services.nextcloud.dataDir = "${serverDataDir}/nextcloud";
    # adguard DNS/adblocker :
    services.adguard.enable = true;
    services.adguard.subDomain = "periphery";
    services.adguard.dataDir = "${serverDataDir}/adguard";
  };

  # STORAGE :
  # WIP : Change to ZFS pool with multiple disks as backup !
  fileSystems."${serverDataDir}" = {
    device = "/dev/disk/by-uuid/7721a44c-046d-4799-a216-19636dfc775e";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "compress=zstd" "noatime" ];
  };
  services.btrfs.autoScrub.fileSystems = [ "${serverDataDir}" ];

}
