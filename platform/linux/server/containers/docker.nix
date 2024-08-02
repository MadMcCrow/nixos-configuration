# containers/docker.nix
# how to manage docker/podman containers
{ lib, config, ... }:
let cts = config.nixos.server.containers;
in {
  # interface :
  options.nixos.server.containers = with lib; {
    enable = mkEnableOption "service containers" // { default = false; };
    usePodman = mkEnableOption "replace docker with podman" // {
      default = false; # default to docker instead of podman
    };
  };

  # implementation
  config = {
    virtualisation = lib.mkIf cts.enable (lib.mkMerge [
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
            enable = false;
            daemon.settings = { ipv6 = true; };
            setSocketVariable = true;
          };
          autoPrune.enable = true;
          autoPrune.dates = "daily";
        };
      })
    ]);
  };
}
