# sddm is the login manager for KDE
{ lib, config, ... }:
lib.mkIf config.nixos.desktop.enable {
  services.xserver.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    autoNumlock = true;
    wayland.enable = true;
    # theme =
    settings.General.DisplayServer = "x11-user";
  };
}
