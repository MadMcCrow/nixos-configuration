# linux/web/containers/default.nix
#   nixos containers
{ ... }:
{
  # maybe regroup :
  imports = [
    ./container.nix
    #./networking.nix
    #./proxy.nix
  ];
}
