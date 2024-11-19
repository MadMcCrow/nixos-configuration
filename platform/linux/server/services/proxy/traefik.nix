{ config, lib, ... }:
{
  options.nixos.server.proxy.useTraefik = lib.mkEnableOption "traefik as reverse proxy";

  config = lib.mkIf config.nixos.server.proxy.useTraefik {

    # Enable Traefik
    services.traefik = {
      enable = true;

      # Let Traefik interact with Docker
      group = "docker";

      staticConfigOptions = {
        api.dashboard = true;
        api.insecure = false;

        # Enable logs
        log.filePath = "/var/log/traefik/traefik.log";
        accessLog.filePath = "/var/log/traefik/accessLog.log";

        # Enable Docker provider
        providers.docker = {
          endpoint = "unix:///run/docker.sock";
          watch = true;
          exposedByDefault = false;
        };

        # Configure entrypoints, i.e the ports
        entryPoints = {
          websecure.address = ":443";
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };
        };

        # Configure certification
        certificatesResolvers.acme-challenge.acme = {
          email = config.security.acme.defaults.email;
          storage = "/var/lib/traefik/acme.json";
          httpChallenge.entryPoint = "web";
        };
      };

      # Dashboard
      dynamicConfigOptions.http.routers.dashboard = {
        rule = lib.mkDefault "Host(`traefik.local`)";
        service = "api@internal";
        entryPoints = [ "websecure" ];
        tls = lib.mkDefault true;
        # Add certification
        # tls.certResolver = "acme-challenge";
      };

    };

    # Add Dashboard to hosts
    networking.hosts."127.0.0.1" =
      if
        config.services.traefik.dynamicConfigOptions.http.routers.dashboard.rule == "Host(`traefik.local`)"
      then
        [ "traefik.local" ]
      else
        [ ];
  };
}
