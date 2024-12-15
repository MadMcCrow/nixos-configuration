# base configuration for making bootable isos
{
  pkgs,
  lib,
  nixpkgs,
  addModules
  ...
}:
{

  imports = [
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ]  ++ (addModules ["linux" "desktop"]);

  config = {
    # use the latest Linux kernel
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;

      # basically everything
      supportedFilesystems = lib.mkForce [
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
    };

    desktop.enable = true;

    # packages for using in iso :
    environment.systemPackages = with pkgs; [
      # as much python as one can want :
      python311Full
      python311Packages.pyparted
      python311Packages.btrfsutil
      python311Packages.sh
      python311Packages.rich
      # formatting tools :
      parted
      util-linux
      # shell tools :
      zsh
      wget
      curl
      zip
      neofetch # because its cool ;)
      lshw
      dmidecode
      pciutils
      usbutils
      psensor
      smartmontools
      lm_sensors
      policycoreutils # SELinux tool
      # git :
      git
      git-crypt
      pre-commit
      git-lfs
    ];
  };
}
