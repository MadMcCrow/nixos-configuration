# desktop/environments/default.nix
# 	Nixos Desktop Environments
{ config, pkgs, lib, inputs, ... }: {
  # TODO: 
  # - try lxqt
  # - try to fix xfce
  # - cinnamon improvements (backgrounds)
  # - kde speed and plasma config in nix
  # - lumina for server/low power system
  imports = [
    ./budgie.nix
    ./cinnamon.nix
    ./deepin.nix
    ./gnome.nix
    ./kde.nix
    ./pantheon.nix
    ./xfce.nix
  ];
}
