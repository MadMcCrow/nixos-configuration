# xfce.nix
# 	Nixos xfce Desktop environment settings
{ config, pkgs, lib, ... }:
let
cfg = config.nixos.desktop.xfce;
in
{

  # interface
  options.nixos.desktop.xfce = {
      enable = lib.mkEnableOption "KDE, the QT based desktop environment";
  };
  config = lib.mkIf cfg.enable {
  # TODO: try this https://www.thelinuxrain.org/articles/tutorial-how-to-use-kwin-window-manager-with-xfce
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };
    # TODO:
    nixos.desktop.gtk = with pkgs; {
      # theme.package = cinnamon.mint-themes;
      # theme.name = "Mint-Y";
      # iconTheme.package = cinnamon.mint-themes;
      # iconTheme.name = "Mint-Y";
      # cursorTheme.package = cinnamon.mint-cursor-themes;
      # cursorTheme.name = "XCursor-Pro-Light";
      extra.iconThemes.papirus = true;
    };
    system.nixos.tags = [ "xfce" ];
  };
}
