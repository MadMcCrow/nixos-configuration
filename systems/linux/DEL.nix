# DEL
#   Dell Wyse 5070
#   home lightweight server
{
  config,
  nixos-hardware,
  addModules,
  pkgs,
  ...
}:
{
  imports =
    with nixos-hardware.nixosModules;
    [
      common-gpu-intel
      common-cpu-intel
    ]
    ++ (addModules [
      "linux"
      "web"
      "home/linux"
    ]);

  config = {

  # research-labs because it's for home labing ;)
  networking.hostName = "research";

    # Power Management : minimize consumption
    # TODO : power module 
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
      # scsiLinkPolicy = "med_power_with_dipm"; # maybe it isn't worth to deal with this
    };

    # enable extra layer of security
    security.apparmor.enable = true;

    system.stateVersion = "25.04";
  };
}
