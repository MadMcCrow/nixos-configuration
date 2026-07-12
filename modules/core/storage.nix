# storage.nix
# Define the disk layout using disko
{
  config,
  disko,
  nonOS,
  nonlib,
  ...
}:
with nonlib;
with lib;
let
os = nonOS __curPos {inherit config;};
in
{
  # import disko
  imports = [ disko.nixosModules.disko ];

  options = os.options {
    main = mkOption {
        name = "${os.path}.main";
        description = "The main disk device to use (e.g., /dev/nvme0n1).";
        type = deviceType;
      };
    # global options to avoid hardcoded text
     _persist = mkNonEmptyStrOption "persisting state for ${os.name}" "/etc/${os.name}";
  };

  config = mkIf os.cfg.enable {
      fileSystems = {
        "/" = {
          fsType = "tmpfs";
          options = [
            "size=4G"
            "mode=755"
          ];
        };
        "${os.cfg._persist}" = {
          fsType = "btrfs";
          options = [ "compress=zstd" ];
        };
      };
      # implementation
      disko.devices = {
        nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=4G"
            "mode=755"
          ];
        };
        disk.main = {
          device = os.cfg.main;
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
                    "${os.cfg._persist}" = {
                      mountpoint = "${os.cfg._persist}";
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
