# core/default.nix
# 	Nixos core definitions
{ ... }: {
  imports = [
    ./command
    ./disks
    ./vendors
    ./audio.nix
    ./boot.nix
    ./flatpak.nix
    ./network.nix
    ./nix.nix
    ./vm.nix
    ./wake.nix
  ];
}
