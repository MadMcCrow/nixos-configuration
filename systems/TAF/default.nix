# TAF
#   previously "AF"
#   this is my main desktop PC
{ ... }: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix # makr this generic if other pc with nvidia cards
    ./zfs.nix # older zfs configuration to remove !
  ];
}
