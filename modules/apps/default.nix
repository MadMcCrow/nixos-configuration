# apps/default.nix
# 	all the apps we want on our systems
{ config, pkgs, lib, ... }: {
  imports = [
    ./base.nix
    ./multimedia.nix
    ./vscode.nix
    ./flatpak.nix
    ./brave.nix
    ./discord.nix
    ./chess.nix
  ];
}
