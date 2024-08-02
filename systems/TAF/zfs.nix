# # ZFS - ERASE YOUR DARLINGS :
# TODO : replace with btrfs !
{ lib, pkgs, ... }:
let
  # helper config
  mkZFS = name: device: neededForBoot: {
    inherit name;
    value = {
      inherit device neededForBoot;
      mountPoint = name;
      fsType = "zfs";
    };
  };
in {
  # use latest zfs
  boot.zfs.package = pkgs.zfs;

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];

  # append zfs rollback command :
  boot.initrd.postDeviceCommands =
    lib.mkAfter "zfs rollback -r nixos-pool/local/root@blank";

  # append zfs options :
  boot.extraModprobeConfig =
    lib.mkAfter "options zfs l2arc_noprefetch=0 zfs_arc_max=1073741824";

  # import zfs pools at boot
  boot.zfs = {
    forceImportRoot = false; # if it does not work, switch to false
    forceImportAll = false;
    allowHibernation = true;
  };

  # add subvolumes to fileSystems:
  fileSystems = (builtins.listToAttrs [
    (mkZFS "/" "nixos-pool/local/root" true)
    (mkZFS "/nix" "nixos-pool/local/nix" true)
    (mkZFS "/nix/persist" "nixos-pool/safe/persist" true)
    (mkZFS "/home" "nixos-pool/safe/home" false)
  ]) // {
    "/boot" = {
      device = "/dev/disk/by-uuid/8001-EF00";
      fsType = "vfat";
    };
  };
}
