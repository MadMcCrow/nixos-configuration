# TAF
#   previously "AF"
#   this is my main desktop PC
{ pkgs, ... }: {

  networking.hostName = "trantor"; # previously "nixAF"
  networking.domain = "foundation";

  # enable desktop environment :
  nixos.desktop.enable = true;

  ## enable flatpak apps
  nixos.flatpak.enable = true;

  nixos.boot.sleep = true;
  nixos.boot.fastBoot = true;
  nixos.boot.extraPackages = [
    # asus motherboard
    "asus-wmi-sensors"
    "asus-ec-sensors"
    "nct6687d" # https://github.com/Fred78290/nct6687d
    # zen CPU
    "zenpower"
    # ACPI
    "acpi_call"
  ];

  ## TODO : This is machine specific and should be brought back from core!
  nixos.network.wakeOnLineInterfaces = [ "enp4s0" ];

  # kernel params directly on linux
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "usbcore.autosuspend=-1" ];
  boot.blacklistedKernelModules = [ "xhci_hcd" ];

  # use our zfs setup
  nixos.zfs.enable = true;

  # add steam drive
  # TODO : CLEAN THIS !
  fileSystems."/run/media/steam" = {
    device = "nixos-pool/local/steam";
    fsType = "zfs";
    neededForBoot = false;
  };

  # amd gpu :
  nixos.gpu.vendor = "amd";

  # Power Management :
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  # gaming :
  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
    enableRenice = true;
  };

  # some swap hardware :
  swapDevices = [{
    device = "/dev/disk/by-partuuid/509f2c99-0e63-4af1-90fb-5ff8d76efb67";
    randomEncryption.enable = true;
    randomEncryption.allowDiscards = true; # less secure but better for the SSD
  }];

  system.stateVersion = "23.11";
}
