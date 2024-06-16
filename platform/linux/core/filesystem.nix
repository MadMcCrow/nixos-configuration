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
#   - [ ] encrypt root with luks and TPM see `secureboot.nix`
#   - [ ] Create a disko nix file to create the necessary filesystem
#   - [ ] Install script to prepare that structure
#   - [ ] Make all nixos machines use this 
{ lib, config, ... }:
let
  # shortcut
  cfg = config.nixos.fileSystem;
  # detect encryption :
  isEncrypted = cfg.luks != "";
in {
  # interface
  options.nixos.fileSystem = with lib; {
    # use this shared setup :
    enable = mkEnableOption ''
      use standard root layout with btrfs subvolumes;
    '';
    # btrfs drive partition :
    btrfs = mkOption {
      description = "block device receiving nixos";
      type = types.str;
      default = "/dev/mapper/lvm-nixos";
    };
    # allowfully encrypted root :
    luks = mkOption {
      description = ''
        encrypted block device receiving nixos
        leave empty to disable encrytion
      '';
      type = types.str;
      default = "";
    };
    # boot vfat partition
    boot = mkOption {
      description = "block device receiving /boot";
      type = types.str;
      default = "/dev/disk/by-uuid/8001-EF00";
    };
    # swap file :
    swap = mkOption {
      description = "block device receiving swap";
      type = types.str;
      default = "/dev/mapper/lvm-swap";
    };
    # size of tmpfs for root
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
      device = cfg.boot;
      fsType = "vfat";
    };

    # /nix
    #   Nix store and files
    #   more compression added to save space
    fileSystems."/nix" = {
      device = cfg.btrfs;
      fsType = "btrfs";
      options = [ "subvol=/nix" "lazytime" "noatime" "compress=zstd:5" ];
    };

    # /var
    # Logs and variable for running software
    # Limit disk usage with more compression
    fileSystems."/var" = {
      device = cfg.btrfs;
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
      device = cfg.btrfs;
      fsType = "btrfs";
      options = [
        "subvol=/tmp"
        "lazytime"
        "noatime"
        "nodatacow" # no compression, but cleared on boot
      ];
    };

    # /home
    #   TODO : maybe worth having setup elsewhere ?
    fileSystems."/home" = {
      device = cfg.btrfs;
      fsType = "btrfs";
      options = [ "subvol=/home" "lazytime" "noatime" "compress=zstd" ];
    };

    # some swap hardware :
    swapDevices = lib.lists.optionals (cfg.swap != "") [
    {
      device = cfg.swap;
      randomEncryption = lib.mkIf (!isEncrypted) {
        enable = true;
        allowDiscards = true;
      };
    }];

    # support encryption and decryption at boot
    boot.initrd.luks.devices.cryptroot = lib.mkIf isEncrypted {
      device = cfg.luks;
    };
  };
}
