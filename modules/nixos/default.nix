# nixos/default.nix
#	without it, nixos will not work as intended
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.nixos;
in {
  # enable nixos systems
  option.nixos.enable = mkEnableOption {
    name = mdDoc "Nixos";
    default = true;
  };
  # limit imports to nixos systems
  imports = if cfg.enable then [
    ./filesystems.nix
    ./flatpak.nix
    ./nixos.nix
    ./opengl.nix
    ./security.nix
    ./shell.nix
  ] else
    [ ];
}
