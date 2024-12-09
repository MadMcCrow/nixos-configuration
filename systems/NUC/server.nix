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
  nixos.web = {
    enable = true;

    # bought and paid for !
    domain = "asimov.ovh";

    # email for certificates and notifications
    adminEmail = "noe.perard+serveradmin@gmail.com";
    # auth.subDomain = "kan";
    # dns.subDomain = "periphery";
    # home.subDomain = "imperium";
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
