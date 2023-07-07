# logitech.nix
# 	support for logitech hardware
{config, pkgs ,lib, ...} :
with builtins;
with lib;
let
  nos = config.nixos;
  dsk = nos.desktop;
  cfg = dsk.logitech;
  enable = all (x : x.enable) [nos dsk cfg];
in {

  # interface
  options.nixos.desktop.logitech.enable = mkEnableOption (mdDoc "logitech drivers and software");
  # config
  config = mkIf enable {
    # Xbox Controller Support
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    # Packages
    environment.systemPackages = with pkgs; [
      logitech-udev-rules
      solaar
    ];
    packages.unfreePackages = [ "xow_dongle-firmware" ];
  };
}