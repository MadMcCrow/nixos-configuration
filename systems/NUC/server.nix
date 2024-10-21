# Server specific options for NUC
{ lib, ... }:
let
  enable_server = true; # disabled for installation
  serverDataDir = "/var/www";
in
lib.mkIf enable_server {

  # we are headless : add some way to know if we run normally
  nixos.extra.beep.enable = true;

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
    device = "/dev/mapper/cryptserver";
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae";
      label = "cryptserver"; # luks device
    };
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "compress=zstd:6"
      "noatime"
    ];
  };
  boot.initrd.luks.devices."cryptserver" = {
    device = "/dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae";
    allowDiscards = true;
  };

  services.btrfs.autoScrub.fileSystems = [ "${serverDataDir}" ];

}
