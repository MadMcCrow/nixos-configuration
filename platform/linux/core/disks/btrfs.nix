# linux/core/disks/btrfs.nix
# support running nixos off a btrfs partition
#	  - root btrfs setup for my linux machines
#   - implements the "erase your darling philosophy"
#   - uses latest nixos packages
#
{ config, lib, pkgs, ... }:
let
  # shortcut
  cfg = config.nixos.btrfs;
in {
  # interface
  options.nixos.btrfs = with lib; {
    # TODO : split "supporting btrfs and using it for root"
    enable = mkEnableOption "btrfs root system";

    # label of root block device
    label = mkOption {
      description = "label of master block";
      type = types.str;
      default = "/";
    };

    # root pool :
    rootSubVolume = mkOption {
      description = "system btrfs root subvolume name";
      type = types.str;
      default = "/";
    };

    # blank snapshot
    blank = mkOption {
      description = "snapshot name for empty /local/root";
      type = types.str;
      default = "blank";
    };
  };

  # implementation
  config = lib.mkIf (cfg.enable) {

    assertions = [{
      assertion = !config.nixos.zfs.enable;
      message = "cannot have both btrfs and zfs root!";
    }];

    boot.supportedFilesystems = [ "btrfs" ];
    boot.initrd.supportedFilesystems = [ "btrfs" ];

    services.btrfs.autoScrub.enable = true;
    services.btrfs.autoScrub.interval = "weekly";
    # TODO:
    # services.btrfs.autoScrub.fileSystems
    fileSystems = let
      btrfsMountOptions = [
        "defaults"
        "nodatacow"
        "lazytime"
        "noatime"
        "compress=zstd"
        "autodefrag"
        "nodiscard"
      ];
    in {
      "/" = {
        label = "nixos";
        fsType = "btrfs";
        options = [ "subvol=root" ] ++ btrfsMountOptions;
      };
      "/home" = {
        label = "nixos";
        fsType = "btrfs";
        options = [ "subvol=home" ] ++ btrfsMountOptions;
      };
      "/nix" = {
        label = "nixos";
        fsType = "btrfs";
        options = [ "subvol=nix" ] ++ btrfsMountOptions;
      };
    };

    # append btrfs rollback command :
    # maybe we need to mount root elsewhere first
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      # mount /dev/sdX# /mnt
      mv /@ /@_badroot
      mv /@_snapshot /@
      ${lib.getBin pkgs.btrfs-progs}/bin/btrfs subvolume delete /@_badroot
    '';
  };
}
