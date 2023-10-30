# linux/zfs.nix
#	zfs setup for my linux machines
{ pkgs, config, lib, ... }:
with builtins;
let
  nxs = config.nixos;
  cfg = nxs.zfs;

  # option helper
  mkOptionBase = type: description: default:
    lib.mkOption { inherit type description default; };

  # ZFS
  ## rollback command
  zfsEnable = true; # cfg.zfs.enable;
  pl = cfg.rollback.pool;
  ds = cfg.rollback.dataset;
  sn = cfg.rollback.snapshot;
  sysPool = cfg.systemPool;

  rollbackCommand = "zfs rollback -r ${pl}/${ds}@${sn}";
  zfsModProbConfig = "options zfs l2arc_noprefetch=0 zfs_arc_max=1073741824";

  mkZFS = name: device: neededForBoot: {
    inherit name;
    value = {
      inherit device neededForBoot;
      mountPoint = name;
      fsType = "zfs";
    };
  };

  zFileSystems = listToAttrs (if zfsEnable then [
    (mkZFS "/" "${sysPool}/local/root" true)
    (mkZFS "/nix" "${sysPool}/local/nix" true)
    (mkZFS "/nix/persist" "${sysPool}/safe/persist" true)
    (mkZFS "/home" "${sysPool}/safe/home" false)
  ] else
    [ ]);

in {
  options.nixos.zfs = with lib.types; {
    enable = mkOptionBase bool "enable zfs filesystem" true;
    systemPool = mkOptionBase str "main system pool" "nixos-pool";
    rollback = {
      pool = mkOptionBase str "pool to rollback" "nixos-pool";
      dataset = mkOptionBase str "dataset to rollback" "local/root";
      snapshot = mkOptionBase str "snapshot for rollback" "blank";
    };
  };

  config = lib.mkIf (nxs.enable && cfg.enable) {
    # service:
    services.zfs.trim.enable = cfg.enable;
    services.zfs.autoScrub.enable = cfg.enable;

    # force use zfs compatible kernel :
    nixos.kernel.packages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;

    boot = {
      initrd.postDeviceCommands = lib.mkAfter rollbackCommand;
      extraModprobeConfig =
        lib.mkAfter (if zfsEnable then zfsModProbConfig else "");
      # import zfs pools at boot
      zfs.forceImportRoot = zfsEnable;
      zfs.forceImportAll = zfsEnable;
      zfs.enableUnstable = false;
    };

    fileSystems = zFileSystems;
  };
}
