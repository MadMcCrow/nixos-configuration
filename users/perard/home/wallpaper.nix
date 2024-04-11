# wallpaper.nix
# 	cool wallpaper setup independant of desktop environment ;)
{ pkgs, lib, ... }:
let
  backgrounds = with pkgs; [
    fondo
    variety
    sunpaper
    swww
    cinnamon.mint-artwork
    gnome.gnome-backgrounds
    deepin.deepin-wallpapers
    budgie.budgie-backgrounds
    adapta-backgrounds
  ];

in { home.packages = [ ]; }
