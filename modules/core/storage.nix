# storage.nix
# Define the disk layout using disko
{ config, nonlib, disko, ... }:
with nonlib; {
  imports = [ disko.nixosModules.disko ];
  options.nonOS = {
    _persist = mkOption {
      type = types.storage;
      default = "/etc/nonOS";
    };
  };
} // nonOS __curPos config {
  nonOptions = {
    main = mkMandatoryOption {
      name = "hardware.storage.main";
      description = "The main disk device to use (e.g., /dev/nvme0n1).";
      type = deviceType;
    };
  };
  nonConfig = cfg : {

    fileSystems = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "size=4G" "mode=755" ];
      };
      "${config.nonOS._persist.mountPoint}" = {
        fsType = "btrfs";
        mountOptions = [ "compress=zstd" ];
      };
    };
    # implementation
    disko.devices = {
        nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [ "size=4G" "mode=755" ];
        };
        disk.main = {
          device = cfg.main;
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
                    "nonOS" = {
                      mountpoint =  "${config.nonOS._persist}";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
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
