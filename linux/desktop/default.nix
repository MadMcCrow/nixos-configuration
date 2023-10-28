# desktop/default.nix
# 	Nixos Desktop Environment settings
{ config, pkgs, lib, inputs, ... }:
with builtins;
let
  cfg = config.nixos.desktop;
in {
  options.nixos.desktop.enable = (lib.mkEnableOption "desktop") // {
    default = false;
  };

  imports = [
    ./apps
    ./environments
    ./artwork.nix
    ./display-manager.nix
    ./gtk.nix
  ];
}
