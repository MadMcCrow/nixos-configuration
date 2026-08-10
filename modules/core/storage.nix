# storage.nix
# Define the disk layout using disko
nonOS:
{
  lib,
  config,
  ...
}:
with lib;
with nonOS;
let
  os = mod "storage" config;
  persist = os.cfg._dir;

  # devices can be specified with :
  # - a path (e.g. /dev/sda1)
  # - a device name (e.g. sda1)
  # - a UUID
  # - a label
  # - a partlabel
  # - a device path with UUID (e.g. /dev/disk/by-uuid/)
  # - a device path with label (e.g. /dev/disk/by-label/)
  # - a device path with partlabel (e.g. /dev/disk/by-partlabel/)
  isDevice =
    x:
    if x == null then
      true
    else if isPath x then
      true
    else if isString x then
      true
    else
      false;
in
with os;
{
  options = mkOptions {
    main = mkOption {
      description = "The main disk device to use (e.g., /dev/nvme0n1).";
      type =
        with types;
        addCheck (oneOf [
          str
          path
        ]) isDevice;
    };
  };

  config = mkConfig {
    # filesystems
    fileSystems = {
      "/" = {
        fsType = "tmpfs";
        options = [
          "size=4G"
          "mode=755"
        ];
      };
      "${persist}" = {
        fsType = "btrfs";
        options = [ "compress=zstd" ];
      };
    };

    # use disko :
    disko.devices = {
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=4G"
          "mode=755"
        ];
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
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "${persist}" = {
                    mountpoint = "${persist}";
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
  };
}
