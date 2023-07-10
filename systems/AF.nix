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
    kernel.extraKernelPackages = [ "asus-wmi-sensors" "asus-ec-sensors" "zenpower"];

    # cpu/gpu
    cpu.vendor = "amd";
    cpu.powermode = "performance";
    gpu.vendor = "amd";
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
