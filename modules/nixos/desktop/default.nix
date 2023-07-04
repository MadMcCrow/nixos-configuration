# desktop/default.nix
# 	Nixos Desktop Environment settings
#	todo : add KDE as another module
{ config, pkgs, lib, inputs, ... }:
with builtins;
with lib;
let
  cfg = config.desktop;
  submodules = [ ./gnome.nix ./kde.nix ./flatpak.nix ./apps.nix ./xone.nix];
in {
  options.nixos.desktop.enable = mkEnableOption (mdDoc "desktop") // {
    default = true;
  };
  imports = submodules;
}
