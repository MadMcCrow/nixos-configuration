# linux/server/nextcloud/default.nix
#   all that is necessary for getting nextcloud to work OOTB
#   TODO:
#         - Enable HTTPS
#         - Remote access (ie from outside of my local network)
{ pkgs, config, lib, ... }: {
  imports = [ ./container.nix ];
}
