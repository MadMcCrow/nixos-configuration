# default.nix
#	Collection of modules to enable
#	Add your NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
{ pkgs, config, nixpkgs, lib, unfree, ... }: {
  imports = [ ./ratbag.nix ./input-remapper.nix ./xone.nix ];
}
