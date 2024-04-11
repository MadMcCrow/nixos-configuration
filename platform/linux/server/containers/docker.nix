# containers/docker.nix
# how to manage docker/podman containers
{ lib, config, pkgs, ... }:
let 
srv = config.nixos.server;
cts = config.nixos.server.containers;
in
{
 # interface :
  options.nixos.server.containers = with lib; {
    enable = mkEnableOption "service containers" // {
      default = srv.enable;
    };
    usePodman = mkEnableOption "replace docker with podman" // {
      default = true;
    };
  };
  
  # implementation
  config = lib.mkIf (srv.enable && cts.enable) 
    (lib.MkMerge [
        (lib.attrsets.optionalAttrs cts.usePodman {
          oci-containers.backend = "podman";
          podman = {
            enable = true;
            dockerCompat = true;
            dockerSocket.enable = true;
            autoPrune.enable = true;
            autoPrune.dates = "daily";
          };
        })
        (lib.attrsets.optionalAttrs (!cts.usePodman) 
          {
            oci-containers.backend = "docker";
            virtualisation = {
              docker.rootless = {
                enable = true;
                daemon.settings = {
                  ipv6 = true;
                };
              };
              autoPrune.enable = true;
              autoPrune.dates = "daily";
            };
          })
    ]);
}