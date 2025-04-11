# SCP
#   Samsung chromebook pro
#   lightweight device with very minimal performance
{ nixos-hardware, addModules, ... }:
{
  imports =
    with nixos-hardware.nixosModules;
    [
      common-gpu-intel
      common-cpu-intel
    ]
    ++ (addModules [
      "linux"
      "home/linux"
      "desktop"
    ]);

  config = {

    networking.hostName = "smyrno";

    # our config :
    nixos = {
      flatpak.enable = true;
    };

    # Power Management : minimize consumption
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
    };

    system.stateVersion = "24.11";
  };
}
