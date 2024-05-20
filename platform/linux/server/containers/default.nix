# containers/default.nix
# import all relevant containers, setup podman
{ lib, config, pkgs, ... }: {
  imports = [
    # docker config :
    ./docker.nix
    # services :
    ./adguard.nix
    ./home-assistant.nix
    ./nextcloud.nix
  ];
}
