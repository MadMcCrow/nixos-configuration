# NUC Cloud config
{ config, lib, pkgs, ... }: 
with config; {

  # our settings
  nixos = {
    enable = true;

    host.name = "nixNUC";

    # desktop env
    desktop.gnome.enable = true;
    desktop.gnome.superExtraApps = true;

    # kernel packages
    kernel.extraKernelPackages = with nixos.kernel.packages; [
      intel-speed-select
      phc-intel
    ];

    # xbox controller
    input.xone.enable = true;

    # cpu
    cpu.vendor = "intel";
    cpu.powermode = "powersave";

    # server :
    server.enable = true;
  };

  # maybe consider adding swap ?
  swapDevices = [ ];
}
