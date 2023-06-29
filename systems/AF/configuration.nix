# configuration.nix
# 	base configuration for Nixos on my desktop
{ config, pkgs, lib, ... }: {
  # import Hardware configuration
  imports = [ ./hardware-configuration.nix ];

  # boot and kernel
  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    extraModulePackages = with config.boot.kernelPackages; [
      zfs
      asus-wmi-sensors
      asus-ec-sensors
      xone
      zenpower
    ];
    kernelParams = [ "nohibernate" "quiet" ];

    # UEFI boot loader with systemdboot
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 3;
    };

    # custom initrd options
    initrd = {
      availableKernelModules =
        [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" "amdgpu" ];
    };

    plymouth.enable = true;
  };


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

  #X11  
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" "radeon" ];
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
    cpuFreqGovernor = "performance";
  };

  # Faster boot:
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-fsck.enable = false;

  # TLDR : Do not touch
  system.stateVersion = "22.11";
}
