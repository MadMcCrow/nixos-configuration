# SCP
#   Samsung chromebook pro
#   lightweight device with very minimal performance
{ nixos-hardware, ... }:
{
  imports =
    with nixos-hardware.nixosModules;
    [
      common-gpu-intel
      common-cpu-intel
    ]
    ++ (addModules [
      "linux"
      "desktop"
    ]);

  config = {

    networking.hostName = "smyrno";

    # our config :
    nixos = {
      # filesystem :
      fileSystems = {
        boot.partuuid = "TODO";
        root.partuuid = "TODO";
        swap.enable = true;
      };
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
