# containers/adguard.nix
# adguard is a better alternative to pihole with more options
{ lib, config, pkgs, ... }:
let
  cts = config.nixos.server.containers;
  adg = cts.adguard;
in {
  # interface :
  options.nixos.server.containers.adguard = {
    enable = lib.mkEnableOption "adguard";
    dataDir = lib.mkOption {
      description = "storage path for adguard";
      type = lib.types.path;
      example = "/www/adguard";
    };
  };
  config = lib.mkIf adg.enable {
    # enable oci :
    nixos.server.containers.enable = true;

    # reverse proxy
    # services.nginx.virtualHosts."adguard.${config.networking.domain}" = rec {
    #   enableACME = config.security.acme.acceptTerms;
    #   addSSL = enableACME;
    #   forceSSL = addSSL;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:3000";
    #     proxyWebsockets = true;
    #   };
    # };

    # Simple configuration based off  https://hub.docker.com/r/adguard/adguard
    virtualisation.oci-containers.containers."adguard" = {
      autoStart = true;
      hostname = "adguard." + config.networking.domain;
      image = "adguard/adguardhome";
      # volume
      volumes =
        [ "./workdir:${adg.dataDir}/work" "./confdir:${adg.dataDir}/conf" ];
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "784:784/udp"
        "853:853/tcp"
        "3000:3000/tcp"
        "443:443/tcp"
      ];
      environment = { TZ = "Europe/Paris"; };
    };
  };
}
