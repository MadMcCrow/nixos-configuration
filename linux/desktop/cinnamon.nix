# cinnamon.nix
# 	Nixos Kde Desktop environment settings
{ config, pkgs, lib, ... }:
with builtins;
let
cfg = config.nixos.desktop.cinnamon;
inherit (pkgs) cinnamon;
in {
  options.nixos.desktop.cinnamon = {
    enable = lib.mkEnableOption "cinnamon desktop environment";
  };

  config = lib.mkIf cfg.enable {

    # make other module use the mint theme
    nixos.desktop.gtk = {
      theme.package = cinnamon.mint-themes;
      theme.name = "Mint-Y";
      iconTheme.package = cinnamon.mint-themes;
      iconTheme.name = "Mint-Y";
      cursorTheme.package = cinnamon.mint-cursor-themes;
      cursorTheme.name = "XCursor-Pro-Light";
      extra.iconThemes.papirus = true;
      extra.gtkThemes.stilo = true;
    };

    system.nixos.tags = [ "Cinnamon" ];

    services.cinnamon.apps.enable = false;
    environment.cinnamon.excludePackages = [ ];

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
