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
    # TODO: try this https://www.thelinuxrain.org/articles/tutorial-how-to-use-kwin-window-manager-with-xfce
    services.xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
        xfce.noDesktop = false;
        xfce.enableXfwm = true;
      };
      displayManager.defaultSession = "xfce";
    };

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # TODO:
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
