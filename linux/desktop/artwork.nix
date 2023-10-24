# gtk.nix
# 	unique configuration for all gtk themes
{ config, pkgs, lib, ... }:
with builtins;
let
  dsk = config.nixos.desktop;
  cfg = dsk.artwork;

  tools = with pkgs; [fondo variety sunpaper swww];
in
{
  options.nixos.desktop.artwork = {
    enable = lib.mkEnableOption "artworks (background)" // {default= true;};
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cinnamon.mint-artwork
      gnome.gnome-backgrounds
      deepin.deepin-wallpapers
      adapta-backgrounds
      ] ++ tools;
  };
}
