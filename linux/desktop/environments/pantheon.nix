# environments/Pantheon.nix
# 	Pantheon is the desktop environment of Elementary linux
{ config, pkgs, lib, ... }:
with builtins;
let
  dsk = config.nixos.desktop;
  cfg = dsk.pantheon;
in {
  options.nixos.desktop.pantheon = {
    enable = lib.mkEnableOption "pantheon desktop environment";
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

    system.nixos.tags = [ "pantheon" ];

    # necessary packages
    environment.systemPackages = with pkgs; [ dconf2nix ];

    # remove what I don´t like :
    environment.pantheon.excludePackages = [ pkgs.pantheon.elementary-camera ];

    # maybe do :
    # services.xserver.displayManager.lightdm.greeters.pantheon.enable = true
    services.pantheon.apps.enable = true;
    # desktop-wide extension service
    services.pantheon.contractor.enable = true;
    # allow easy config
    programs.pantheon-tweaks.enable = true;
    # support for flatpak
    xdg.portal.extraPortals = [ pkgs.pantheon.xdg-desktop-portal-pantheon ];
    services.xserver = {
      enable = true;
      desktopManager.pantheon.enable = true;
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };
}
