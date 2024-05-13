# core/default.nix
# 	Nixos core definitions
{ ... }: {
  imports = [
    ./disks
    ./gpu
    ./audio.nix
    ./boot.nix
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
