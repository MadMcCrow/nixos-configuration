# containers/nextcloud.nix
# NEXTCLOUD from the linux server team
{ lib, config, pkgs, ... }:
let
  cts = config.nixos.server.containers;
  nxc = cts.nextcloud;
in {
  # interface :
  options.nixos.server.containers.nextcloud = {
    enable = lib.mkEnableOption "nextcloud server";
    dataDir = lib.mkOption {
      description = "storage path for nextcloud";
      type = lib.types.path;
      example = "/www/nextcloud";
    };
  };
  config = lib.mkIf nxc.enable {
    # force enable oci if nextcloud is asked :
    nixos.server.containers.enable = true;

    # reverse proxy
    # services.nginx.virtualHosts."nextcloud.${config.networking.domain}" = rec {
    #   enableACME = config.security.acme.acceptTerms;
    #   addSSL = enableACME;
    #   forceSSL = addSSL;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:443";
    #     proxyWebsockets = true;
    #   };
    # };

    # Simple configuration based off https://github.com/nextcloud/all-in-one/blob/main/compose.yaml
    virtualisation.oci-containers.containers."nextcloud" = {
      autoStart = true;
      hostname = "nextcloud." + config.networking.domain;
      image = "lscr.io/linuxserver/nextcloud:latest";
      volumes = [ "${nxc.dataDir}/config:/config" "${nxc.dataDir}/data:/data" ];
      ports = [ "443:443" "8443:8443" "8080:8080" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Paris";
      };
    };
  };
}
