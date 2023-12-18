# environments/deepin.nix
# 	deepin is the desktop environment of Deepin linux, a chinese distro
{ config, pkgs, lib, ... }:
with builtins;
let
  dsk = config.nixos.desktop;
  cfg = dsk.dde;
in {
  options.nixos.desktop.dde = {
    enable = lib.mkEnableOption "deepin desktop environment";
  };

  config = lib.mkIf (dsk.enable && cfg.enable) {

    # make other module use the mint theme
    nixos.desktop.gtk = let themes = config.nixos.desktop.gtk.extra;
    in {
      theme = themes.gtkThemes.stilo.theme;
      iconTheme = themes.iconThemes.papirus.theme;
      cursorTheme = themes.iconThemes.numix-cursor.theme;
      extra.iconThemes.papirus.enable = true;
      extra.iconThemes.numix-cursor.enable = true;
      extra.gtkThemes.stilo.enable = true; # windows like borders
    };

    system.nixos.tags = [ "DDE" ];

    # necessary packages
    environment.systemPackages = with pkgs; [
      dconf2nix
      gnome.gnome-terminal
      gnome.gnome-screenshot
    ];

    # bad taste remove :
    environment.deepin.excludePackages = with pkgs;
      [
        #??
      ];

    # maybe disable superfluous
    services.deepin.app-services.enable = true;
    services.deepin.dde-api.enable = true;
    services.deepin.dde-daemon.enable = true;

    services.xserver = {
      # enable GUI
      enable = true;

      desktopManager.deepin.enable = true;
      # remove xterm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-xapp ];
  };
}
