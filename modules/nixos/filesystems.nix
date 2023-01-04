# filesystems.nix
# 	set the supported filesystem on my nix systems
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.filesystems;
  defaultFilesystems =
    [ "btrfs" "ext2" "ext3" "ext4" "f2fs" "fat8" "fat16" "fat32" "ntfs" "zfs" ];
in {
  # interface
  options.nixos.filesystems = {
    # force replace override
    enable = mkEnableOption (mdDoc " default Supported filesystem types") // {
      default = true;
    };
    # overridable list
    list = mkOption {
      type = types.listOf types.str;
      default = defaultFilesystems;
      description = "Supported filesystem types. ";
    };
  };

  # override config
  config =
    mkIf (nos.enable && cfg.enable) { boot.supportedFilesystems = cfg.list; };
}
