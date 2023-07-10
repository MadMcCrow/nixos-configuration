# NUC Cloud config
{ pkgs, ... }: 
{
# our settings
  nixos = {
    enable = true;
    host.name = "nixNUC";

    # let's be generous with ourselves
    rebuild.genCount = 10;

    # desktop env
    desktop.enable = true;
    desktop.gnome.enable = true;

    # kernel packages
    kernel.extraKernelPackages = [ "intel-speed-select" "phc-intel"];

    # cpu/gpu
    cpu.vendor = "intel";
    cpu.powermode = "powersave";
    gpu.vendor = "intel";
    
    # server :
    server.enable = true;
  };

  # maybe consider adding swap ?
  swapDevices = [ ];
}
