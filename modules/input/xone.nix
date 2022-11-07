# xone.nix
# 	a driver for the xbox one controller and its dongle
{ config, pkgs, lib, boot, unfree, ... }:
with builtins;
with lib;
let
  cfg = config.input.xone;
  kernel = config.boot.kernelPackages;
in {
  # interface
  options.input.xone = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = ''
        xone is a kernel level driver for the xbox one controller from Microsoft,
        as well as the official Microsoft dongle
      '';
    };
  };

  config = lib.mkIf cfg.enable {
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
