# SCP
# Samsung Chromebook Pro (Caroline)
# this is an old chromebook running NixOS on top of MrChromebox UEFI
{ pkgs, ... }: {
  #
  networking.hostName = "smyrno"; # "Smyrno";
  networking.domain = "foundation";

  # this one does not use zfs
  nixos.btrfs.enable = true;

  nixos.flatpak.enable = true;
  nixos.gpu.vendor = "intel";
  nixos.boot.extraPackages = [ "acpi_call" ];

  # PowerManagement
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave"; # try to optimise that batterie
    powertop.enable = true;
  };

  # Kernel Params :
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "usbcore.autosuspend=-1" ];
  boot.blacklistedKernelModules = [ "xhci_hcd" ];

  # maybe consider adding swap ?
  swapDevices = [ ];
  system.stateVersion = "23.11";
}
