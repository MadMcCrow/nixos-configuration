# TAF
#   previously "AF"
#   this is my main desktop PC
{ pkgs, ... }: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ];
}
