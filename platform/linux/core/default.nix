# core/default.nix
# 	Nixos core definitions
{ ... }:
{
  imports = [
    ./audio.nix
    ./boot.nix
    ./filesystem.nix
    ./fonts.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./secureboot.nix
    ./security.nix
    ./vm.nix
    ./wake.nix
  ];
}
