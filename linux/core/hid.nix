# hid.nix
# Human Interface Device
# TODO : find better name than HID
# TODO : support remote
{ pkgs, lib, config, ... }:
let
  # shortcuts :
  dsk = config.nixos.desktop;
  cfg = dsk.HID;
in {
  # option
  options.nixos.desktop.HID = {
    enable = lib.mkEnableOption "Human interface Devices" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    hardware = {
      xone.enable = true;
      logitech.wireless.enable = true;
      logitech.wireless.enableGraphical = false;
      steam-hardware.enable = true; # Steam udev rules
    };
    packages.unfreePackages = [
      "xow_dongle-firmware" # xbox dongle
      "steam-original" # steam controller
    ];
  };
}
