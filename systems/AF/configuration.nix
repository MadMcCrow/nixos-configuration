# configuration.nix
# 	base configuration for Nixos on my desktop
{ config, pkgs, lib, ... }: {
  # import Hardware configuration
  imports = [ ./hardware-configuration.nix ];

  # boot and kernel
  boot = {

    # use Zen for better performance

    kernelPackages = pkgs.linuxPackages_xanmod;
    extraModulePackages = with config.boot.kernelPackages; [ zfs asus-wmi-sensors ];
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
      kernelModules = [ "dm-snapshot" ];
      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r nixos-pool/local/root@blank
      '';
    };

    # filesystems
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
    zfs = {
      forceImportRoot = false;
      forceImportAll = false;
      enableUnstable = false;
    };
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
    homeMode = "700";
    hashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
  };

  # Packages
  environment.systemPackages = with pkgs; [
    xow_dongle-firmware # for xbox controller
    boot.kernelPackages.xone
  ];

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
