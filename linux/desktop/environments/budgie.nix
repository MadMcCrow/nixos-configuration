# environments/budgie.nix
# 	Budgie is a fork of Gnome3
{ config, pkgs, lib, ... }:
with builtins;
let
dsk = config.nixos.desktop;
cfg = dsk.budgie;
inherit (pkgs) budgie;
in {
  options.nixos.desktop.budgie = {
    enable = lib.mkEnableOption "budgie desktop environment";
  };

  config = lib.mkIf (dsk.enable && cfg.enable)  {

    # make other module use the mint theme
    nixos.desktop.gtk = let
    themes = config.nixos.desktop.gtk.extra;
    in {
      theme = themes.gtkThemes.stilo.theme;
      iconTheme = themes.iconThemes.papirus.theme;
      cursorTheme = themes.iconThemes.numix-cursor.theme;
      extra.iconThemes.papirus.enable = true;
      extra.iconThemes.numix-cursor.enable = true;
      extra.gtkThemes.stilo.enable = true; # windows like borders
    };

    system.nixos.tags = [ "budgie" ];

    # necessary packages
    environment.systemPackages = with pkgs; [
    dconf2nix
    gnome.gnome-terminal
    gnome.gnome-screenshot
    ];

    # bad taste themes :
    environment.budgie.excludePackages = with pkgs; [
      #??
     ];

    services.xserver = {
      # enable GUI
      enable = true;

      desktopManager.budgie.enable = true;
      # remove xterm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };
}
