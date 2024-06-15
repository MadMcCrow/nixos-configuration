# filesystems/root.nix
# default root configuration.
# root on tmpfs uses around 11MB, what takes space is mostly /tmp.
# to avoid this issue, we have a filesystem dedicated to /tmp
# /var can also take a lot of space so we move it to another filesystem
# what's left is less than 1MB. 
# that's not the most optimized RAM setup, but I think all my machines can support losing that space.
# TLDR :
#   here's the layout :
#     - / -> tmpfs
#     - /var  -> btrfs
#     - /nix  -> btrfs
#     - /tmp  -> btrfs, clean on boot, CoW disabled (no checksum)
#     - /home -> btrfs
# TODO:
#   - [ ] encrypt root with luks and TPM
#   - [ ] Create a disko nix file to create the necessary filesystem
#   - [ ] Install script to prepare that structure
#   - [ ] Make all nixos machines use this 
{ lib, config, ... }:
let
  # shortcut
  cfg = config.nixos.fileSystem;
in {
  # interface
  options.nixos.fileSystem = with lib; {
    enable = mkEnableOption "use standard root layout with btrfs subvolumes";
    device = mkOption {
      description = "block device receiving nixos";
      type = types.str;
    };
    bootPartition = mkOption {
      description = "block device receiving /boot";
      type = types.str;
    };
    tmpfsSize = mkOption {
      description = "Size of tmpfs for root";
      type = types.str;
      default = "100M";
    };
  };
  # implementation
  config = lib.mkIf cfg.enable {

    # enable btrfs on the machine :
    boot.supportedFilesystems = [ "btrfs" ];
    boot.initrd.supportedFilesystems = [ "btrfs" ];
    services.btrfs.autoScrub.enable = true;
    services.btrfs.autoScrub.interval = "weekly";

    # /
    #   root is always tmpfs
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=${cfg.tmpfsSize}" "mode=755" ];
    };

    # /boot
    #    Boot is always an Fat32 partition like old times
    fileSystems."/boot" = {
      device = cfg.bootPartition;
      fsType = "vfat";
    };

    # /nix
    #   Nix store and files
    #   more compression added to save space
    fileSystems."/nix" = {
      device = cfg.device;
      fsType = "btrfs";
      options = [ "subvol=/nix" "lazytime" "noatime" "compress=zstd:5" ];
    };

    # /var
    # Logs and variable for running software
    # Limit disk usage with more compression
    fileSystems."/var" = {
      device = cfg.device;
      fsType = "btrfs";
      options = [
        "subvol=/var"
        "compress=zstd:6" # higher level, default is 3
      ];
    };

    # /tmp
    #   cleared on boot, not important
    boot.tmp.cleanOnBoot = true;
    fileSystems."/tmp" = {
      device = cfg.device;
      fsType = "btrfs";
      options = [
        "subvol=/tmp"
        "lazytime"
        "noatime"
        "nodatacow" # no compression, but cleared on boot
      ];
    };

    # /home
    #   maybe worth having setup elsewhere ?
    fileSystems."/home" = {
      device = cfg.device;
      fsType = "btrfs";
      options = [ "subvol=/home" "lazytime" "noatime" "compress=zstd" ];
    };
  };
}
