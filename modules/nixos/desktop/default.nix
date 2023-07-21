# desktop/default.nix
# 	Nixos Desktop Environment settings
#	TODO : regroup KDE/gnome
# TODO : regroup xone/logitech
{ config, pkgs, lib, inputs, ... }:
with builtins;
with lib;
let
  cfg = config.desktop;
  submodules = [ ./gnome.nix ./flatpak.nix ./apps.nix ./xone.nix ./logitech.nix];
in {
  options.nixos.desktop.enable = (mkEnableOption "desktop") // {
    default = true;
  };
  imports = submodules;
}
