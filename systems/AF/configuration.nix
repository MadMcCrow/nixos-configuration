# this is my base configuration for Nixos
{ config, pkgs, lib, ... }:

{

  # imports
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot = {
    # use Zen for better performance
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "nohibernate" "quiet" ];
    # UEFI boot loader with systemdboot
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 2;
    };
    # custom initrd options
    initrd = {
      availableKernelModules =
        [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" "zfs" ];
      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r nixos-pool/local/root@blank
      '';
    };
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
    plymouth.enable = true;
    zfs.forceImportAll = false;
  };

  # zfs
  services.zfs.trim.enable = true;

  # Networking
  networking.hostName = "nixAF"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.hostId = "104e6fea";

  # Timezone
  time.timeZone = "Europe/Paris";
  services.timesyncd.servers = [ "fr.pool.ntp.org" "europe.pool.ntp.org" ];

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "intl";
    xkbOptions = "eurosign:e";
  };

  # disable CUPS
  services.printing.enable = false;

  # root user
  users.users.root = {
    #home = "/home/root"; # this does not work
    homeMode = "700";
    hashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
  };

  # Packages
  environment.systemPackages = with pkgs; [
    xow_dongle-firmware # for xbox controller
    linuxKernel.packages.linux_zen.xone
  ];

  # Packages config
  nixpkgs.config = {
    allowUnfree = true;
    chromium = { enableWideVine = true; };
    packageOverrides = pkgs: {
      system-path = pkgs.system-path.override {
        xterm = pkgs.gnome.gnome-terminal;
      };
    };
  };


  # Documentation
  documentation = {
    nixos.enable = true;
    man.enable = true;
    doc.enable = false;
  };

  # PowerManagement
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
  
  # Faster boot:
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-fsck.enable = false;

  # Xbox Controller Support
  hardware.xone.enable = true;
  hardware.firmware = [ pkgs.xow_dongle-firmware ];
  
  # make sure opengl is supported
  hardware.opengl.enable = true;

  # TLDR : Do not touch
  system.stateVersion = "22.05";
}
