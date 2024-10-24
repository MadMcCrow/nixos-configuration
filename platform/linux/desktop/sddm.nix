# sddm is the login manager for KDE
{ lib, config, ... }:
let
  useNvidia = builtins.any (x: x == "nvidia") config.services.xserver.videoDrivers;
in
lib.mkIf config.nixos.desktop.enable {
  services.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    autoNumlock = true;
    # this prevents issues with nvidia drivers
    wayland.enable = !useNvidia;
  };
}
