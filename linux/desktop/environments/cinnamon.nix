# environments/cinnamon.nix
# 	cinnamon is a fork of Gnome3 to look like gnome2
{ config, pkgs, lib, ... }:
with builtins;
let
  dsk = config.nixos.desktop;
  cfg = dsk.cinnamon;
  inherit (pkgs) cinnamon;
in {
  options.nixos.desktop.cinnamon = {
    enable = lib.mkEnableOption "cinnamon desktop environment";
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

    system.nixos.tags = [ "Cinnamon" ];

    # disable superfluous
    services.cinnamon.apps.enable = false;

    # necessary packages
    environment.systemPackages = with pkgs; [
      dconf2nix
      gnome.gnome-terminal
      gnome-calculator
      gnome.gnome-screenshot
    ];

    # bad taste themes :
    environment.cinnamon.excludePackages = with pkgs; [
      cinnamon.mint-y-icons
      cinnamon.mint-x-icons
      cinnamon.mint-themes
    ];

    services.xserver = {
      # enable GUI
      enable = true;

      desktopManager.cinnamon.enable = true;
      # remove xterm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };
}
