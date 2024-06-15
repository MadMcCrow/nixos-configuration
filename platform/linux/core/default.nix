# core/default.nix
# 	Nixos core definitions
{ ... }: {
  imports = [
    ./audio.nix
    ./filesystem.nix
    ./kernel.nix
    ./network.nix
    ./nix.nix
    ./secureboot.nix
    ./tools.nix
    ./vm.nix
    ./wake.nix
  ];
}
