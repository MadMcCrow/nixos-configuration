# containers/home-assistant.nix
{ lib, config, pkgs, ... }:
let
  cts = config.nixos.server.containers;
  hma = cts.home-assistant;
  port = 8123;
in {
  # interface :
  options.nixos.server.containers.home-assistant = with lib; {
    enable = mkEnableOption "home-assistant";
    dataDir = mkOption {
      description = "storage path for home-assistant";
      type = types.path;
      example = "/www/home-assistant";
    };
    subDomain = mkOption {
      description = "subdomain to use for nextcloud service";
      type = with types;
        nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+)" s) != null));
      default = "nextcloud";
    };
  };
  config = lib.mkIf hma.enable {
    # enable oci-containers
    nixos.server.containers.enable = true;

    # redirect via reverse proxy :
    services.nginx.enable = true;
    services.nginx.virtualHosts."${hma.subDomain}.${config.nixos.server.domainName}" = rec {
      enableACME = config.security.acme.acceptTerms;
      addSSL = enableACME;
      # forceSSL = enableACME;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString port}/";
        # proxyWebsockets = true;
      };
    };

    # Simple configuration based off  https://hub.docker.com/r/home-assistant/home-assistant
    virtualisation.oci-containers.containers."home-assistant" = {
      autoStart = true;
      hostname = "${hma.subDomain}.${config.nixos.server.domainName}";
      image = " homeassistant/home-assistant:stable";
      # devices:
      #   - "/dev/serial/by-id/usb-0658_0200-if00-port0:/dev/ttyACM0"
      # volume
      volumes = [ "./config:/${hma.dataDir}/userdata" ];
      ports = [ (let s = builtins.toString port; in "${s}:${s}") ];
      environment = { TZ = "Europe/Paris"; };
    };
  };
}
