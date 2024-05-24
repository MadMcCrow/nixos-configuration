# containers/home-assistant.nix
{ lib, config, pkgs, ... }:
let
  cts = config.nixos.server.containers;
  hma = cts.home-assistant;
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

    # reverse proxy
    # services.nginx.virtualHosts."home-assistant.${config.networking.domain}" =
    #   rec {
    #     enableACME = config.security.acme.acceptTerms;
    #     addSSL = enableACME;
    #     forceSSL = addSSL;
    #     locations."/" = {
    #       proxyPass = "http://127.0.0.1:8123";
    #       proxyWebsockets = true;
    #     };
    #   };

    # Simple configuration based off  https://hub.docker.com/r/home-assistant/home-assistant
    virtualisation.oci-containers.containers."home-assistant" = {
      autoStart = true;
      hostname = "${hma.subDomain}.${config.nixos.server.domainName}";
      image = " homeassistant/home-assistant:stable";
      # devices:
      #   - "/dev/serial/by-id/usb-0658_0200-if00-port0:/dev/ttyACM0"
      # volume
      volumes = [ "./config:/${hma.dataDir}/userdata" ];
      ports = [ "8123:8123" ];
      environment = { TZ = "Europe/Paris"; };
    };
  };
}
