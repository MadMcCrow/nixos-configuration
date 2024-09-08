# hardware/hid.nix
# support for logitech mouses
{ lib, config, ... }:
let
  cfg = config.nixos.vendor.logitech;
in
{
  # interface :
  options.nixos.vendor.logitech = with lib; {
    enable = mkEnableOption "logitech hardware";
  };
  # merge all options :
  config = lib.mkIf cfg.enable {
    hardware.logitech = {
      wireless.enable = true;
      wireless.enableGraphical = false;
      lcd.startWhenNeeded = true;
    };
  };
}
