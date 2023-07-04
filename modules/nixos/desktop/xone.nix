{config, pkgs ,lib, ...} :
with builtins;
with lib;
let
  nos = config.nixos;
  dsk = nos.desktop;
  cfg = dsk.xone;

  enable = all (x : x.enable) [nos dsk cfg];
in {

  # interface
  options.nixos.desktop.xone.enable = mkEnableOption (mdDoc "XBox One driver");
  # config
  config = mkIf enable {
    # Xbox Controller Support
    hardware = {
      xone.enable = true;
      firmware = [ pkgs.xow_dongle-firmware ];
    };
    # Packages
    environment.systemPackages = with pkgs; [
      xow_dongle-firmware # for xbox controller
      config.boot.kernelPackages.xone
    ];
    packages.unfreePackages = [ "xow_dongle-firmware" ];
  };
}