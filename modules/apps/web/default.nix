# apps/web/default.nix
# 	all the apps we want on our systems
{ pkgs, config, nixpkgs, lib, unfree, ... }: {
  imports = [
    ./firefox.nix
    ./brave.nix
    ./discord.nix
    ./pidgin.nix
    ./signal.nix
    ./rustdesk.nix
  ];
}
