# linux/server/services.nix
#   nixos native services to run on a server
{ ... }:
{
  imports = [
    ./nextcloud
    ./adguard.nix
  ];
}
