# containers/docker.nix
# how to manage docker/podman containers
{ lib, config, pkgs, ... }:
let
  srv = config.nixos.server;
  cts = config.nixos.server.containers;
in {
  # interface :
  options.nixos.server.containers = with lib; {
    enable = mkEnableOption "service containers" // { default = srv.enable; };
    usePodman = mkEnableOption "replace docker with podman" // {
      default = false; # default to docker instead of podman
    };
  };

  # implementation
  config = {
    virtualisation = lib.mkIf srv.enable (lib.mkMerge [
      (lib.attrsets.optionalAttrs cts.usePodman {
        oci-containers.backend = "podman";
        podman = {
          enable = cts.enable;
          dockerCompat = true;
          dockerSocket.enable = true;
          autoPrune.enable = true;
          autoPrune.dates = "daily";
        };
      })
      (lib.attrsets.optionalAttrs (!cts.usePodman) {
        oci-containers.backend = "docker";
        docker = {
          enable = cts.enable;
          rootless = {
            enable = true;
            daemon.settings = { ipv6 = true; };
          };
          autoPrune.enable = true;
          autoPrune.dates = "daily";
        };
      })
    ]);
  };
}
