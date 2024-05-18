# hardware-configuration.nix
# hardware specific stuff :
{ config, ...} : {
boot.extraModulePackages = map (x: config.boot.kernelPackages."${x}") [
    # asus motherboard
    "asus-wmi-sensors"
    "asus-ec-sensors"
    "nct6687d" # https://github.com/Fred78290/nct6687d
    # zen CPU
    "zenpower"
    # ACPI
    "acpi_call"
  ];
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "usbcore.autosuspend=-1" ];
  boot.blacklistedKernelModules = [ "xhci_hcd" ];

  ## TODO : This is machine specific and should be brought back from core!
  nixos.network.wakeOnLineInterfaces = [ "enp4s0" ];

  # some swap hardware :
  swapDevices = [{
    device = "/dev/disk/by-partuuid/509f2c99-0e63-4af1-90fb-5ff8d76efb67";
    randomEncryption.enable = true;
    randomEncryption.allowDiscards = true; # less secure but better for the SSD
  }];
}
