# core/default.nix
# 	Nixos core definitions
{ ... }:
{
  imports = [
    ./filesystems.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./ssh.nix
  ];
}
