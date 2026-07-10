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
let
os = nonOS __curPos {inherit config;};
in
{
  # import disko
  imports = [ disko.nixosModules.disko ];

  options = {
    # global options to avoid hardcoded text
     _persist = mkNonEmptyStrOption "persisting state for ${os.name}" "/etc/${os.name}";
  } //
  os.options {
    main = mkMandatoryOption {
        name = "${os.path}.main";
        description = "The main disk device to use (e.g., /dev/nvme0n1).";
        type = deviceType;
      };
  };

  config = {
      fileSystems = {
        "/" = {
          fsType = "tmpfs";
          options = [
            "size=4G"
            "mode=755"
          ];
        };
        "${config._persist}" = {
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
                    "${config._persist}" = {
                      mountpoint = "${config._persist}";
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
