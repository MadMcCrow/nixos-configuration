# containers/default.nix
# import all relevant containers, setup podman
{ lib, config, pkgs, ... }:
let srv = config.nixos.server;
in {
  imports = [ ./nextcloud.nix ];

  # interface :
  options.nixos.server.containers = {
    enable = lib.mkEnableOption "service containers" // {
      default = srv.enable;
    };
  };
  # implementation
  config = lib.mkIf (srv.enable && srv.containers.enable) {
    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
      };
    };
  };
}
