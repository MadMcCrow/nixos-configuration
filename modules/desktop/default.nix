# desktop/default.nix
# 	Nixos Desktop Environment settings
#	todo : add KDE as another module
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.desktop;
  submodules = [ ./gnome.nix ./hyprland.nix ./pantheon.nix ];
in {
  option.desktop.enable = mkEnableOption {
    name = mdDoc "desktop";
    default = true;
  };
  imports = if cfg.enable then submodules else [ ];
}
