# environments/xfce.nix
# 	Nixos xfce Desktop environment settings
{ config, pkgs, lib, ... }:
let
  dsk = config.nixos.desktop;
  cfg = dsk.xfce;
in {

  # interface
  options.nixos.desktop.xfce = { enable = lib.mkEnableOption "XFCE"; };
  config = lib.mkIf (dsk.enable && cfg.enable) {
    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
      desktopManager.xfce.enableXfwm = false;
      # desperately trying to get xfce to work
      windowManager = {
        metacity.enable = true;
      };

    };

    environment.systemPackages = (with pkgs.xfce; [xfwm4 xfwm4-themes xfdesktop xfdashboard garcon]);

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # TODO: theming for xfce
    nixos.desktop.gtk = with pkgs; {
      # theme.package = cinnamon.mint-themes;
      # theme.name = "Mint-Y";
      # iconTheme.package = cinnamon.mint-themes;
      # iconTheme.name = "Mint-Y";
      # cursorTheme.package = cinnamon.mint-cursor-themes;
      # cursorTheme.name = "XCursor-Pro-Light";
      extra.iconThemes.papirus.enable = true;
    };
    system.nixos.tags = [ "xfce" ];
  };
}
