# nixos/default.nix
#	without it, nixos will not work as intended
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  cfg = config.nixos;
  submodules = [
    ./filesystems.nix
    ./flatpak.nix
    ./nix.nix
    ./opengl.nix
    ./security.nix
    ./shell.nix
    ./utils.nix
  ];
in {
  # enable nixos systems
  options.nixos.enable = mkEnableOption (mdDoc "nixos") // { default = true; };
  # limit imports to nixos systems
  imports = submodules;
}
