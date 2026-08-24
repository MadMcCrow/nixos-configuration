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
in
with os;
{
  imports = [ nonOS.inputs.disko.nixosModules.disko ];

  options = mkOptions {
    encrypted = mkEnableOption "disk encryption" // {
      default = true;
    };

    # main disk option :
    main = mkOption {
      description = "The main disk device to use (e.g., /dev/nvme0n1).";
      type =
        with types;
        oneOf [
          str
          path
        ];
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
      # TMPFS
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=4G"
          "mode=755"
        ];
      };
      # main disk format
      disk.main = {
        type = "disk";
        device = cfg.main;

        content = {
          type = "gpt";

          # partitions
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            "${nonOS.name}" =
              let
                btrfsPartition = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  # volumes
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
                  # ~ volumes
                };
              in
              {
                type = "8300"; # GPT Linux filesystem
                size = "100%";
                priority = 2;
                content =
                  if cfg.encrypted then
                    {
                      type = "luks";
                      name = "crypted"; # container name in /dev/mapper/
                      content = btrfsPartition;
                    }
                  else
                    btrfsPartition;
              };
          };
        };
        # ~ partitions
      };
    };
  };
}
