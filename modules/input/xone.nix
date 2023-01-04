# xone.nix
# 	a driver for the xbox one controller and its dongle
{ config, pkgs, lib, boot, unfree, ... }:
with builtins;
with lib;
let
  ipt = config.input;
  cfg = ipt.xone;
  kernel = config.boot.kernelPackages;
in {
  # interface
  options.input.xone.enable = mkEnableOption (mdDoc
    "xone, a kernel level driver for the xbox one controller from Microsoft, as well as the official Microsoft dongle ");
  # config
  config = lib.mkIf (ipt.enable && cfg.enable) {
    # allow xow dongle firmware
    unfree.unfreePackages = [ "xow_dongle-firmware" ];
    # Xbox Controller Support
    hardware.xone.enable = true;
    hardware.firmware = [ pkgs.xow_dongle-firmware ];
    # Packages
    environment.systemPackages = with pkgs; [
      xow_dongle-firmware # for xbox controller
      kernel.xone
    ];
  };
}
