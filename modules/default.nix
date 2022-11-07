# default.nix
#	Collection of modules to enable
#	Add your NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
{ pkgs, config, nixpkgs, lib, unfree, ... }:
let unfree = import unfree.nix;
in { imports = [ ./core ./apps ./audio ./desktop ./users ./input ]; }
