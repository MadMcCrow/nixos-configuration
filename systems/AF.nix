{ pkgs, ... }: 
{

  # our settings
  nixos = {
    enable = true;
    host.name = "nixAF";

    rebuild.genCount = 10;

    # desktop env
    desktop = {
      enable = true;
      # use gnome as it's more stable than KDE
      gnome.enable = true;
      xone.enable = true;  # xbox controller
      logitech.enable = true;
    };

    # kernel packages
    kernel.extraKernelPackages = [ "asus-wmi-sensors" "asus-ec-sensors" "zenpower" "acpi_call" ];
    kernel.params = ["pci=noats" "amd_iommu=on" "iommu=pt"];
    
    # cpu/gpu
    cpu.vendor = "amd";
    cpu.powermode = "performance";
    gpu.vendor = "amd";

    network.waitForOnline = false;
    network.wakeOnLineInterfaces = ["enp4s0"];
  };

  # Add support for logitech drivers : 
  hardware.logitech.wireless.enable = true;

  # add steam drive
  fileSystems."/run/media/steam" = {
    device = "nixos-pool/local/steam";
    fsType = "zfs";
    neededForBoot = false;
  };

  # maybe consider adding swap ?
  swapDevices = [ ];
}
