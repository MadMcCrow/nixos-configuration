# filesystems.nix
# 	set the supported filesystem on my nix systems
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.nixos.filesystems;
  defaultFilesystems =
    [ "btrfs" "ext2" "ext3" "ext4" "f2fs" "fat8" "fat16" "fat32" "ntfs" "zfs" ];
in {
  # interface
  options.nixos.filesystems = {
    # force replace override
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "override default Supported filesystem types. ";
    };
    # overridable list
    list = mkOption {
      type = types.listOf types.str;
      default = defaultFilesystems;
      description = "Supported filesystem types. ";
    };
  };

  # override config
  config = mkIf cfg.enable { boot.supportedFilesystems = cfg.list; };
}
