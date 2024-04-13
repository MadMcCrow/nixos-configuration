# containers/default.nix
# import all relevant containers, setup podman
{ lib, config, pkgs, ... }: {
  imports = [ ./docker.nix ./nextcloud.nix ];
}
