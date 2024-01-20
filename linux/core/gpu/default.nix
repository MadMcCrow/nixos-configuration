# gpu/amdgpu.nix
# 	Nixos gpu config for amd
{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.nixos.gpu;
  vendorList = [ "amd" "intel" "nvidia" ];
in {
  options.nixos.gpu.vendor = lib.mkOption {
    description = " GPU vendor : "
      + (builtins.concatStringsSep "," [ (toString vendorList) ]);
    type = lib.types.enum vendorList;
    default = builtins.elemAt vendorList 0;
  };
  imports = [ ./amdgpu.nix ./intel.nix ];
}
