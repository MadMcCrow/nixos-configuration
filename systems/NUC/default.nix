# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{ nixos-hardware, ... }:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./server.nix
  ];
}
