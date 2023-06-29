# desktop/default.nix
# 	Nixos Desktop Environment settings
#	todo : add KDE as another module
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.desktop;
  submodules = [ ./gnome.nix ./kde.nix ./flatpak.nix];
in {
  options.desktop.enable = mkEnableOption (mdDoc "desktop") // {
    default = true;
  };
  imports = submodules;
}
