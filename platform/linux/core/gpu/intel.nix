# gpu/intel.nix
# 	Nixos gpu config for intel
{ config, pkgs, lib, inputs, ... }: {
  config = lib.mkIf (config.nixos.gpu.vendor == "intel") {
    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [ intel-media-driver vaapiIntel ];
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
