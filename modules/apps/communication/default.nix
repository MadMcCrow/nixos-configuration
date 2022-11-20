# apps/communication/default.nix
# 	all the apps we want on our systems
#   
{ pkgs, config, nixpkgs, lib, unfree, ... }: {
  imports = [ ./rustdesk.nix ./discord.nix ./pidgin.nix ];
}
