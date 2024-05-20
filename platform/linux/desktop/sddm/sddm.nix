# sddm is the login manager for KDE
{lib, ... } :
lib.mkIf config.nixos.desktop.enable {
  services.xserver.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    settings.General.DisplayServer = "x11-user";
  };
}
