# desktop/xfce.nix
# 	XFCE FOR DESKTOP
{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.nixos.desktop.enable {
  # set tag for version
  system.nixos.tags = [ "XFCE" ];

  #
  services.xserver.enable = true;

  # enable xfce
  services.xserver.desktopManager.xfce = {
    enable = true;
  };
  # disable xterm
  services.xserver.desktopManager.xterm.enable = false;

}
