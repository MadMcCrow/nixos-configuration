# ISO
#
#   We build custom isos to speed up installation
{ ... }:
{
  imports = [
    ./configuration.nix
    ./packages.nix
  ];
}
