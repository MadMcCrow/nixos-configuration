# SCP
# Samsung Chromebook Pro (Caroline)
# this is an old chromebook running NixOS on top of MrChromebox UEFI
{ pkgs, ... }: {
  #
  networking.hostName = "smyrno"; # "Smyrno";

  # this one does not use zfs
  nixos.btrfs.enable = true;

  nixos.flatpak.enable = true;
  nixos.gpu.vendor = "intel";

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
  system.stateVersion = "24.05";
}
