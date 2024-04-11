# TAF
#   previously "AF"
#   this is my main desktop PC  
{ pkgs, ... }: {
  networking.hostName = "Trantor"; # "nixAF"
  nixos.desktop.enable = true;
  nixos.flatpak.enable = true;
  nixos.desktop.steamSession.enable = true;
  nixos.gpu.vendor = "amd";
  nixos.boot.extraPackages =
    [ "asus-wmi-sensors" "asus-ec-sensors" "nct6687d" "zenpower" "acpi_call" ];

  # TODO : This is machine specific and should be brought back from core!
  nixos.network.wakeOnLineInterfaces = [ "enp4s0" ];

  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "usbcore.autosuspend=-1" ];
  boot.blacklistedKernelModules = [ "xhci_hcd" ];

  # add steam drive
  fileSystems."/run/media/steam" = {
    device = "nixos-pool/local/steam";
    fsType = "zfs";
    neededForBoot = false;
  };

  # nixos.server.enable = true;
  # nixos.server.nextcloud.dataPath =  "/run/server/nextcloud";
  # fileSystems."/run/server" = {
  #   device = "none";
  #     fsType = "tmpfs";
  #     options = [ "size=3G" "mode=755" ]; # mode=755 so only root can write to those files
  # };

  # maybe consider adding swap ?
  swapDevices = [ ];

  system.stateVersion = "23.11";
}
