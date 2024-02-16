# linux/tv.nix
#	Nixos on TV boxes
{ pkgs, config, lib, ... }:
let mkPrio = value: lib.mkOverride 50 value;
in {

  options.nixos.tv.enable = lib.mkEnableOption "nixos TV experience";

  # imports
  imports = [ ./kiosk ./kodi ];

  # config
  config = lib.mkIf config.nixos.tv.enable {

    # xOrg
    #services.xserver = {
    #  enable = mkPrio true;
    #  excludePackages = [ pkgs.xterm ];
    #  desktopManager.xterm.enable = false;
    #};

    # zsh can be used as default shell
    programs.zsh.enable = true;

    boot = {
      # hide wall-of-text
      plymouth.enable = mkPrio true;

      # support everything
      supportedFilesystems = [ "ext3" "ext4" "fat32" "exfat" "ntfs" "zfs" ];

      # UEFI boot loader with systemdboot
      loader = {
        systemd-boot.enable = true; # use gummyboot for faster boot
        systemd-boot.configurationLimit = 10; # make sure TV works !
        efi.canTouchEfiVariables = true;
      };
      consoleLogLevel = mkPrio 2; # only critical errors !
    };

    # PowerManagement
    powerManagement = {
      enable = true;
      cpuFreqGovernor = mkPrio "ondemand"; # try powersave
      powertop.enable = true;
    };

    # enable rendering
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    services.xserver.enable = mkPrio true;

    # TODO : decide what's best :
    # Faster boot:
    # systemd.services.NetworkManager-wait-online.enable = false;
    # systemd.services.systemd-fsck.enable = false;

    # flatpak support :
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-xapp
    ];
    xdg.portal.config.common.default = [ "xapp" ];

    #
    system.nixos.tags = [ "TV" ];
    system.stateVersion = "23.11";

    # disable nixos manual : just use the web version !
    documentation.nixos.enable = mkPrio false;
  };
}
