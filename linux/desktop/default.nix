# desktop/environments/default.nix
# 	Nixos Desktop Environment
#   TODO :
#     - if KDE gets better, switch to KDE
#     -
{ config, pkgs, lib, ... }:
let mkPrio = value: lib.mkOverride 100 value;
in {

  options.nixos.desktop.enable = lib.mkEnableOption "NIXOS desktop experience";

  imports = [ ./gnome.nix ];

  config = lib.mkIf config.nixos.desktop.enable {
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
      vulkan-tools
      stremio
    ];

    # zsh can be used as default shell
    programs.zsh.enable = true;

    boot = {
      plymouth.enable = mkPrio true; # hide wall-of-text
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
      loader.systemd-boot.configurationLimit = 5;
      consoleLogLevel = mkPrio 3; # avoid useless errors
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
    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.services.systemd-fsck.enable = false;

    # disable nixos manual : just use the web version !
    system.nixos.tags = [ "Desktop" ];
    system.stateVersion = "23.11";

    documentation.nixos.enable = mkPrio false;
  };
}
