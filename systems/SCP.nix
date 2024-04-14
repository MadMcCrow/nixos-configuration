# SCP
# Samsung Chromebook Pro (Caroline)
# this is an old chromebook running NixOS on top of MrChromebox UEFI
{ pkgs, ... }: {
  #
  networking.hostName = "Smyrno"; # "Smyrno";
  nixos.desktop.enable = true;
  nixos.flatpak.enable = true;
  nixos.gpu.vendor = "intel";
  nixos.boot.extraPackages = [ "acpi_call" ];

  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "usbcore.autosuspend=-1" ];
  boot.blacklistedKernelModules = [ "xhci_hcd" ];
  # maybe consider adding swap ?
  swapDevices = [ ];
  system.stateVersion = "23.11";
}
