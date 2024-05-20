# gpu/intel.nix
# 	Nixos gpu config for intel
{ pkgs-latest, lib, config, ... }:
let cfg = config.nixos.intel;
in {

  options.nixos.intel = with lib; {
    cpu.enable = mkEnableOption "Intel CPU specific configuration";
    gpu.enable = mkEnableOption "Intel GPU specific configuration";
  };

  config = with lib;
    mkMerge [
      # CPU config
      (mkIf cfg.cpu.enable {
        # CPU:
        hardware.enableRedistributableFirmware = true;
        hardware.cpu.intel.updateMicrocode = true;
      })
      (mkIf cfg.gpu.enable {
        # GPU :
        hardware.opengl = {
          enable = true;
          extraPackages = with pkgs-latest; [ intel-media-driver vaapiIntel ];
          driSupport = true;
          driSupport32Bit = true;
        };
      })
    ];
}
