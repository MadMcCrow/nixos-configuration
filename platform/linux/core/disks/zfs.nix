# linux/core/disks/zfs.nix
# support running nixos off a zfs volume
#	  - root zfs setup for my linux machines
#   - implements the "erase your darling philosophy"
#   - uses latest nixos packages
#
#   TODO: auto setup and creation of blank snapshot for the first instantiation
{ config, lib, pkgs-latest, ... }:
let
  # shortcut
  cfg = config.nixos.zfs;
in {

  # interface
  options.nixos.zfs = with lib; {
    # TODO : split "supporting zfs and using it for root"
    enable = mkEnableOption "zfs root system";

    # root pool :
    pool = mkOption {
      description = "system zfs pool name";
      type = types.str;
      default = "nixos-pool";
    };

    # blank snapshot
    blank = mkOption {
      description = "snapshot name for empty /local/root";
      type = types.str;
      default = "blank";
    };

    # simple option for easier setup
    isSetup = mkEnableOption "keep zfs in a setup state (import-all, etc)" // {
      default = true;
    };
  };

  # implementation
  config = lib.mkIf cfg.enable {

    # use latest zfs
    boot.zfs.package = pkgs-latest.zfs;
    boot.kernelPackages =
      lib.mkForce pkgs-latest.zfs.latestCompatibleLinuxPackages;

    services.zfs.trim.enable = true;
    services.zfs.autoScrub.enable = true;

    boot.supportedFilesystems = [ "zfs" ];
    boot.initrd.supportedFilesystems = [ "zfs" ];

    # append zfs rollback command :
    boot.initrd.postDeviceCommands =
      lib.mkAfter "zfs rollback -r ${cfg.pool}/local/root@${cfg.blank}";

    # append zfs options :
    boot.extraModprobeConfig =
      lib.mkAfter "options zfs l2arc_noprefetch=0 zfs_arc_max=1073741824";

    # import zfs pools at boot
    boot.zfs.forceImportRoot = true;

    # disable once your setup is correct
    boot.zfs.forceImportAll = cfg.isSetup;

    # allow hibernation
    boot.zfs.allowHibernation = !cfg.isSetup;

    # add subvolumes to fileSystems:
    fileSystems = let
      mkZFS = name: device: neededForBoot: {
        inherit name;
        value = {
          inherit device neededForBoot;
          mountPoint = name;
          fsType = "zfs";
        };
      };
    in (builtins.listToAttrs [
      (mkZFS "/" "${cfg.pool}/local/root" true)
      (mkZFS "/nix" "${cfg.pool}/local/nix" true)
      (mkZFS "/nix/persist" "${cfg.pool}/safe/persist" true)
      (mkZFS "/home" "${cfg.pool}/safe/home" false)
    ]);

  };
}
