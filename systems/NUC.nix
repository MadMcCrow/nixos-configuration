# NUC Cloud config
{ pkgs, ... }: 
let
# todo filter broken
#intel kernel packages can be broken sometimes
intelKernelPackages =  [ 
  # "intel-speed-select" # broken
  # "phc-intel" # broken
  ];
in
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
    kernel.extraKernelPackages = [ "acpi_call" ];

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
