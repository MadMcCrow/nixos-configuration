# base configuration for making bootable isos
{
  pkgs,
  lib,
  nixpkgs,
  ...
}:
{

  imports = [ "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # basically everything
  boot.supportedFilesystems = lib.mkForce [
    "ext2"
    "ext4"
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
    "cifs"
  ];

}
