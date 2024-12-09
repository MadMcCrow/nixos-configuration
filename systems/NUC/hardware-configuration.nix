# hardware-configuration.nix
# using nixos maintained configuration
{ nixos-hardware, ... }:
{
  # HARDWARE :
  imports = with nixos-hardware.nixosModules; [
    common-gpu-intel
    common-cpu-intel
  ];

  config = {
    # Power Management : minimize consumption
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
      # scsiLinkPolicy = "med_power_with_dipm"; # maybe it isn't worth to deal with this
    };
    services.thermald.enable = true;
  };
}
