# linux/server/services.nix
#   services to run on a server
#
{ pkgs, config, lib, ... }: {
  imports = [
    # ./dns.nix
    ./nextcloud
  ];
}
