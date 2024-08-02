# filesystems/root.nix
# default root configuration.
# root on tmpfs uses around 11MB, what takes space is mostly /tmp.
# to avoid this issue, we have a filesystem dedicated to /tmp
# /var can also take a lot of space so we could move it to another filesystem
# we just focus on var/log because that could be useful to keep
# what's left is less than 1MB. 
# that's not the most optimized RAM setup, but I think all my machines can support losing that space.
# TLDR :
#   here's the layout :
#     - / -> tmpfs
#     - /var/log  -> btrfs, CoW disabled (no checksum)
#     - /nix      -> btrfs
#     - /tmp      -> btrfs, clean on boot, CoW disabled (no checksum)
#     - /home     -> btrfs
#
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
    swap = mkEnableOption "swap partition";
    # vfat /boot partition drive partition :
    boot = mkOption {
      description = "block device receiving bootloader";
      type = types.str;
    };
    # allow fully encrypted root :
    luks = mkOption {
      description = ''
        encrypted block device receiving nixos
        leave empty to disable encrytion
      '';
      type = types.str;
      default = "";
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
    boot.supportedFilesystems = [ "btrfs" "fat32" ];
    boot.initrd.supportedFilesystems = [ "btrfs" "fat32" ];
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
      label = "nixos";
      fsType = "btrfs";
      options = [ "subvol=/nix" "lazytime" "noatime" "compress=zstd:5" ];
    };

    # /var/log
    # Logs and variable for running software
    # Limit disk usage with more compression
    fileSystems."/var/log" = {
      label = "nixos";
      fsType = "btrfs";
      options = [
        "subvol=/log"
        "compress=zstd:6" # higher level, default is 3
      ];
    };

    # /var/lib
    # data from running software
    # fast access with lower compression
    # TODO : check if this is necessary
    # fileSystems."/var/lib" = {
    #   label =  "nixos";
    #   fsType = "btrfs";
    #   options = [
    #     "subvol=/lib"
    #     "compress=zstd:2" # higher level, default is 3
    #   ];
    # };

    # /tmp
    #   cleared on boot, not important
    boot.tmp.cleanOnBoot = true;
    fileSystems."/tmp" = {
      label = "nixos";
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
      label = "nixos";
      fsType = "btrfs";
      options = [ "subvol=/home" "lazytime" "noatime" "compress=zstd" ];
    };

    # some swap hardware :
    swapDevices = with lib;
      lists.optionals (cfg.swap) [{
        label = "swap";
        randomEncryption = mkIf (!isEncrypted) {
          enable = true;
          allowDiscards = true;
        };
        # there's no need to do this, because it
        # will be on the same encrypted disk as 
        # root.
        #encrypted = mkIf isEncrypted {
        #  enable = true;
        #  device = cfg.luks;
        #};
      }];

    # support encryption and decryption at boot
    boot.initrd.luks.devices.cryptroot = lib.mkIf isEncrypted {
      device = cfg.luks;
      allowDiscards = true;
    };
  };
}
