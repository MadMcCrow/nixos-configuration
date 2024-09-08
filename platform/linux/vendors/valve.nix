# vendor/valve.nix
# support for valve hardware 
{ lib, config, ... }:
let
  # shortcut :
  cfg = config.nixos.vendor.valve;
in
{
  # interface :
  options.nixos.vendor.valve = with lib; {
    enable = mkEnableOption "valve hardware (steam controller, Vive, ...)";
  };

  config = lib.mkIf cfg.enable {
    hardware.steam-hardware.enable = true; # Steam udev rules
    programs.steam.extest.enable = true;
    nixos.nix.unfreePackages = [ "steam-original" ];
  };
}
