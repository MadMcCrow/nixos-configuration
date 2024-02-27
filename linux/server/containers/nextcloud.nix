# containers/nextcloud.nix
# nextcloud container
{ lib, config, pkgs, ... }:
let cts = config.nixos.server.containers;
in {
  config = lib.mkIf cts.enable {
    virtualisation.oci-containers.containers.it-tools = {
      autoStart = true;
      image = "nextcloud/all-in-one:latest";
      ports = [ "8080:80" ];
    };
  };
}
