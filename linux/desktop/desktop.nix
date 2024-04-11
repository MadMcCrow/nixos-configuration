# desktop.nix
#   base config for a nixos desktop
{ config, pkgs, lib, ... }:
let
  inherit (lib) mkDefault;
  mkPrio = value: lib.mkOverride 100 value;
in lib.mkIf config.nixos.desktop.enable {
  # xOrg
  services.xserver = {
    enable = mkPrio true;
    excludePackages = [ pkgs.xterm ];
    desktopManager.xterm.enable = false;
  };

  environment.defaultPackages = with pkgs; [
    lshw
    dmidecode
    pciutils
    usbutils
    psensor
    smartmontools
    lm_sensors
    cachix
    vulnix
    git
    git-crypt
    pre-commit
    git-lfs
    age
    stremio
  ];

  # zsh can be used as default shell
  programs.zsh.enable = true;

  boot = {
    plymouth.enable = mkDefault true; # hide wall-of-text
    # support everything
    supportedFilesystems = [
      "btrfs"
      "ext2"
      "ext3"
      "ext4"
      "f2fs"
      "fat8"
      "fat16"
      "fat32"
      "ntfs"
      "zfs"
    ];
    loader.systemd-boot.configurationLimit = mkDefault 5;
    consoleLogLevel = mkDefault 3; # avoid useless errors
  };

  # PowerManagement
  powerManagement = {
    enable = true;
    cpuFreqGovernor = mkPrio "performance";
    powertop.enable = true;
  };
  # a desktop thing :
  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
    enableRenice = true;
  };

  # enable openGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Faster boot:
  systemd.services.NetworkManager-wait-online.enable = mkDefault false;
  systemd.services.systemd-fsck.enable = mkDefault false;

  system.nixos.tags = [ "Desktop" ];
  system.stateVersion = "23.11";

  # disable nixos manual : just use the web version !
  documentation.nixos.enable = mkPrio false;
}
