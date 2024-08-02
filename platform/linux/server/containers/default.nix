# containers/default.nix
# import all relevant containers, setup podman
{ ... }: {
  imports = [
    # docker config :
    ./docker.nix
    # services :
    ./home-assistant.nix
    ./nextcloud.nix
  ];
}
