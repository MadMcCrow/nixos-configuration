# desktop/default.nix
# 	Nixos Desktop Environment settings
#	todo : add KDE as another module
{ config, pkgs, lib, ... }: {
  imports = [ ./gnome.nix ];
}
