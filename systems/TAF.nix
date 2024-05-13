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

  # server test
  nixos.server.adminEmail = "noe.perard@gmail.com";
  # these are docker images :
  nixos.server.containers.home-assistant.enable = true;
  nixos.server.containers.home-assistant.dataDir = "/run/server/homeassistant";
  nixos.server.containers.adguard.enable = true;
  nixos.server.containers.adguard.dataDir = "/run/server/adguard";
  # nixos.server.containers.nextcloud-linux-server.enable = true;
  # nixos.server.containers.nextcloud-linux-server.dataDir = "/run/server/ncslc";
  # avoid using this : it's slow As F
  # nixos.server.containers.nextcloud-aio.enable = true;
  # nixos.server.containers.nextcloud-aio.dataDir = "/run/server/nextcloud-docker";

  # these are nixos-containers :
  nixos.server.services.nextcloud.enable = true;
  nixos.server.services.nextcloud.dataDir = "/run/server/nextcloud";

  fileSystems."/run/server" = {
    device = "none";
    fsType = "tmpfs";
    options =
      [ "size=3G" "mode=755" ]; # mode=755 so only root can write to those files
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

  # maybe consider adding swap ?
  swapDevices = [ ];

  system.stateVersion = "23.11";
}
