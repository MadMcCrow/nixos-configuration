{ pkgs, ... }: {
  networking.hostName = "nixAF";

  nixos.desktop.enable = true;
  nixos.flatpak.enable = true;

  nixos.gpu.vendor = "amd";
  nixos.boot.extraPackages =
    [ "asus-wmi-sensors" "asus-ec-sensors" "zenpower" ];

  # TODO : This is machine specific and should be brought back from core!
  nixos.network.wakeOnLineInterfaces = [ "enp4s0" ];

  boot.initrd.availableKernelModules =
    [ "pci=noats" "amd_iommu=on" "iommu=pt" ];

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
