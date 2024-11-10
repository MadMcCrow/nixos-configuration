# nginx is a webserver, used mostly as a reverse proxy 
{ config, lib, ... }:
let
  # shortcuts
  cfg = config.nixos.server.proxy.nginx;
  domain = config.nixos.server.domainName;

  # custom option for building proxies
  proxyOption =
    with lib;
    with lib.types;
    submodule {
      options = {
        host = mkOption {
          type = nullOr str;
          description = "hostname to reverse proxy";
          default = null;
        };
        subDomain = mkOption {
          type = nullOr str;
          description = "subdomain to reverse proxy (we find host with server domain)";
          default = null;
        };
        port = mkOption {
          type = int;
          description = "port to redirect to";
        };
        forceSSL = mkOption {
          type = bool;
          description = "set to true to force SSL";
          default = false;
        };
        protocol = mkOption {
          type = str;
          description = "protocol to use";
          default = "http";
        };
        address = mkOption {
          type = str;
          description = "IPv4 address";
          default = "127.0.0.1";
        };
      };
    };
in
{
  options.nixos.server.proxy.nginx = with lib; {
    hosts = mkOption {
      description = "list of proxies to add to nginx";
      default = null;
      type = types.nullOr (types.nonEmptyListOf (proxyOption));
    };
  };

  config = lib.mkIf (cfg.hosts != null) {
    services.nginx = {
      enable = true;
      # Use recommended settings
      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;

      # add every virtualHosts :
      virtualHosts = builtins.listToAttrs (
        map (x: {
          name = if (x.host != null) then x.host else "${x.subDomain}.${domain}";
          value = rec {
            enableACME = config.security.acme.acceptTerms;
            addSSL = enableACME && !x.forceSSL;
            forceSSL = enableACME && x.forceSSL;
            locations."/" = {
              proxyPass = "${x.protocol}://${x.address}:${builtins.toString x.port}/";
              proxyWebsockets = true;
            };
          };
        }) cfg.hosts
      );
    };

    # end of config  
  };
}
