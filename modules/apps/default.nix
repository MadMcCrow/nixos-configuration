# apps/default.nix
# 	all the apps we want on our systems
{ pkgs, config, nixpkgs, lib, unfree, ... }: {
  imports = [
    ./development # separate folder
    ./web
    ./communication
    ./base.nix
    ./multimedia.nix
    ./flatpak.nix
    ./chess.nix
    ./steam.nix
  ];
}
