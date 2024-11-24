# linux/web/containers/default.nix
#   nixos containers
{ config, lib, ... } :
{
  # maybe regroup :
  imports = [
    ./container.nix
    ./networking.nix
    ./proxy.nix
  ];
}
