# apps/default.nix
# 	all the apps we want on our systems
{ config, pkgs, lib, ... }: {
  imports = [
    ./unfree.nix
    ./base.nix
    ./multimedia.nix
    ./development.nix
    ./flatpak.nix
    ./brave.nix
    ./pidgin.nix
    ./discord.nix
    ./chess.nix
    ./rustdesk.nix
    ./steam.nix
  ];
}
