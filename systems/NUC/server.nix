# Server specific options for NUC
{ ... }:
let
  serverDataDir = "/var/www";
in
{
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
    services.adguard.subDomain = "periphery"; # as opposed to the imperium
    services.adguard.dataDir = "${serverDataDir}/adguard";
  };

  # STORAGE :
  # Encrypted NUC SSD :
  fileSystems."${serverDataDir}" = {
    label = "cryptserver";
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "compress=zstd:6"
      "noatime"
    ];
  };
  boot.initrd.luks.devices."cryptserver" = {
    device = "/dev/disk/by-partuuid/e61ad058-918a-4e23-aa4b-04290a63ded4";
    allowDiscards = true;
  };

  services.btrfs.autoScrub.fileSystems = [ "${serverDataDir}" ];

}
