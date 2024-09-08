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

    # security : do not run as root :
    # settings.General.DisplayServer = "x11-user";
    # theme = TODO
    #
    # [General]
    # background=/usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png
    # type=image
    #
  };
}
