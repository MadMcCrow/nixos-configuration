# gpu/intel.nix
# 	Nixos gpu config for intel
{ config, pkgs, lib, inputs, ... }: {
  config = lib.mkIf (config.nixos.gpu.vendor == "intel") {
    hardware.opengl.extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
    ];
  };
}
