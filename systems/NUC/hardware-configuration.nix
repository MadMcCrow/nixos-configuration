{ config, lib, pkgs, ... }:
let btrfsRootDevice = "/dev/disk/by-uuid/56943bbf-7206-4e7c-800f-edc9c78621cf";
in {
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "weekly";
  # TODO:
  # services.btrfs.autoScrub.fileSystems

  # BTRFS ROOT FILESYSTEM :
  fileSystems = let
    btrfsDevice = subvolume: {
      device = btrfsRootDevice;
      fsType = "btrfs";
      options = [
        "subvol=${subvolume}"
        "lazytime"
        "noatime"
        "compress=zstd"
      ];
    };
  in {
    "/" = btrfsDevice "root";
    "/home" = btrfsDevice "home";
    "/nix" = btrfsDevice "nix";
    "/boot" = {
      device  = "/dev/disk/by-uuid/8001-EF00";
      fsType  = "vfat";
    };
  };

  boot.initrd.postDeviceCommands = pkgs.lib.mkAfter ''
    # mount the root
    mkdir -p /mnt
    mount -o subvol=/ ${btrfsRootDevice} /mnt
    # remove any subvolume of root
    btrfs sub list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      btrfs subvolume delete "/mnt/$subvolume"
    done
    # delete root
    btrfs sub delete /mnt/root
    # write root as a rw snapshot of our blank
    btrfs sub snapshot /mnt/root-blank /mnt/root
    # we can unmount /mnt and continue on the boot process.
    #umount /mnt
  '';

  # let's have some swap partition
  swapDevices = [{
    device = "/dev/disk/by-partuuid/f0a00102-0eee-4065-91e5-d32b89552ce4";
    randomEncryption.enable = true;
    randomEncryption.allowDiscards = true; # less secure but better for the SSD
  }];
}
