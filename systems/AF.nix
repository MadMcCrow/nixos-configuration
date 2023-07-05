{ pkgs, ... }: 
{

  # our settings
  nixos = {
    enable = true;

    host.name = "nixAF";

    # desktop env
    desktop = {
      enable = true;
      # use gnome
      kde.enable = true;
      xone.enable = true;  # xbox controller
    };

    # kernel packages
    kernel.extraKernelPackages = [ "asus-wmi-sensors" "asus-ec-sensors" "zenpower"];

    # cpu/gpu
    cpu.vendor = "amd";
    cpu.powermode = "performance";
    gpu.vendor = "amd";
  };

  # add steam drive
  fileSystems."/run/media/steam" = {
    device = "nixos-pool/local/steam";
    fsType = "zfs";
    neededForBoot = false;
  };

  # maybe consider adding swap ?
  swapDevices = [ ];
}
