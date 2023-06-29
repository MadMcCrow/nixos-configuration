# nixos/zfs.nix
# 	zfs rollback support 
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.zfs;
  
  # generate rollback command
  pl = cfg.rollback.pool;
  ds = cfg.rollback.dataset;
  sn = cfg.rollback.snapshot
  rollbackCommand = "zfs rollback -r ${pl}/${ds}@${sn}"
in {
  # interface
  options.nixos.zfs = {
    enable = mkEnableOption (mdDoc "zfs filesystem") // {
    default = nos.enable;
    };
    rollback = {
      pool = mkOption {
        default = "nixos-pool";
        type = types.string;
      };
      dataset = mkOption {
        default = "local/root";
        type = types.string;
      };
      snapshot = mkOption {
        default = "blank";
        type = types.string;
      };
    }
  };

  # config
  config = lib.mkIf cfg.enable {
    boot = {
      initrd = {
        kernelModules = [ "dm-snapshot" ];
        postDeviceCommands = lib.mkAfter rollbackCommand;
    };
      zfs = {
      forceImportRoot = true;
      forceImportAll = false;
      enableUnstable = false;
    };
    };

    # zfs
    services.zfs.trim.enable = true;
  };
}