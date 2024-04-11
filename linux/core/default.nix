# core/default.nix
# 	Nixos core definitions
{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./gpu
    ./audio.nix
    ./boot.nix
    ./disks.nix
    ./flatpak.nix
    ./fonts.nix
    ./hid.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./shell.nix
    ./upgrade.nix
    ./vm.nix
  ];
}
