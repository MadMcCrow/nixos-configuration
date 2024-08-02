# hardware/hid.nix
# support for logitech mouses
{ lib, config, ... }:
let cfg = config.nixos.vendor.xbox;
in {
  # interface :
  options.nixos.vendor.xbox = with lib; {
    enable = mkEnableOption "xbox hardware (controller, dongle, ...)";
  };
  # merge all options :
  config = lib.mkIf cfg.enable {
    hardware.xone.enable = true;
    nixos.nix.unfreePackages = [ "xow_dongle-firmware" ];
  };
}
