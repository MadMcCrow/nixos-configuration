# apps/games/default.nix
# 	all the apps we want on our systems
{ pkgs, config, nixpkgs, lib, unfree, ... }: {
  imports = [ ./chess.nix ./steam.nix ./gamemode.nix ];
}
