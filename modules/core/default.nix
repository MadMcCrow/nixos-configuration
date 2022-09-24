# core/default.nix
#	without it, nixos will not work as intended
{ pkgs, config, lib, ... }: {
  imports = [ ./shell.nix ./nixos.nix ];
}
