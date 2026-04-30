# storage.nix
# Define the disk layout using disko
{ config, lib, disko, ... }:
{
  # options :`
  options.nonOS.hardware.storage = with lib; {
    main = mkMandatoryOption "The main disk device to use (e.g., /dev/nvme0n1)." types.str;
  };

  # this requires disko
  imports = [ disko.nixosModules.disko ];

  # implementation
  config = {
    disko.devices = {
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [ "size=4G" "mode=755" ];
      };
      disk.main = {
        device = config.nonOS.hardware.storage.main;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/etc/nonOS" = {
                    mountpoint = "/etc/nonOS";
                    mountOptions = [ "compress=zstd" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  # Required for systemd-cryptsetup to work in initrd
  boot.initrd.systemd.enable = true;
};
}
