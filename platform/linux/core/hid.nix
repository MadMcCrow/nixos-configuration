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
    # allow easy remaps with a GUI:
    services.input-remapper = {
      enable = false;
      enableUdevRules = true; # may cause issues with hot-plugs
      serviceWantedBy = [ "graphical.target" ];
    };

    # allow investigation of USB nightmare
    programs.usbtop.enable = true;
    # support various hardware
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

    environment.systemPackages = [ pkgs.steamcontroller ];
  };
}
