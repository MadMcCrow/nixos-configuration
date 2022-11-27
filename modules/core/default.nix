# core/default.nix
#	without it, nixos will not work as intended
{ pkgs, config, lib, ... }: {
  imports = [
    ./filesystems.nix
    ./flatpak.nix
    ./nixos.nix
    ./opengl.nix
    ./security.nix
    ./shell.nix
  ];
}
