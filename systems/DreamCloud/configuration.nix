# configuration.nix
# 	base configuration for Nixos on my desktop
{ config, pkgs, lib, ... }: {
  # import Hardware configuration
  imports = [ ./hardware-configuration.nix ];

  # boot and kernel
  boot = {

    # TODO : change this
    kernelPackages = pkgs.linuxPackages_xanmod;
    extraModulePackages = with config.boot.kernelPackages; [
      zfs
    ];
    kernelParams = [ "quiet" ];

    # UEFI boot loader with systemdboot
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 4;
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
  networking.hostName = "DreamCloud"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.hostId = "";

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

  # PowerManagement
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  # wait for online :
  systemd.services.NetworkManager-wait-online.enable = true;

  # check disks
  systemd.services.systemd-fsck.enable = true;

  # TLDR : Do not touch
  system.stateVersion = "22.11";
}
