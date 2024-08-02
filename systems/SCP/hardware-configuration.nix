# hardware-configuration.nix
# using nixos maintained configuration
{ nixos-hardware, ... }: {
  # HARDWARE :
  imports = with nixos-hardware.nixosModules; [
    common-gpu-intel
    common-cpu-intel
  ];

  # PowerManagement
  config = {
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave"; # try to optimise that batterie
      powertop.enable = true;
    };
  };
}
