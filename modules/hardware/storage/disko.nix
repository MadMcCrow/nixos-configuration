# disko.nix
# Define the disk layout using disko
{ config, ... }: {
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
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                # Enable FIDO2 and TPM2 auto-unlocking
                crypttabExtraOpts = [ "fido2-device=auto" "tpm2-device=auto" ];
              };
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
  };

  # Required for systemd-cryptsetup to work in initrd
  boot.initrd.systemd.enable = true;
}
