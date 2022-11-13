# apps/default.nix
# 	all the apps we want on our systems
{ pkgs, config, nixpkgs, lib, unfree, ... }: {
  imports = [
    ./development # separate folder
    ./base.nix
    ./multimedia.nix
    ./flatpak.nix
    ./brave.nix
    ./pidgin.nix
    ./discord.nix
    ./chess.nix
    ./rustdesk.nix
    ./steam.nix
  ];
}
