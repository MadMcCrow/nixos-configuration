# flatpak.nix
# 	Flatpak support for nixos
{ config, pkgs, lib, impermanence, ... }:
with builtins;
with lib;
let
  cfg = config.core.filesystem;
  defaultFilesystems =
    [ "btrfs" "ext2" "ext3" "ext4" "f2fs" "fat8" "fat16" "fat32" "ntfs" "zfs" ];

in {

  # interface
  options.core.filesystems = {
    # force replace override
    enable = lib.mkOption {
      type = types.bool;
      default = true;
      description = "override default Supported filesystem types. ";
    };
    # overridable list
    list = lib.mkOption {
      type = types.listOf types.str;
      default = defaultFilesystems;
      description = "Supported filesystem types. ";
    };
  };

  # override config
  config = lib.mkIf cfg.enable { boot.supportedFilesystems = cfg.list; };
}
