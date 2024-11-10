# nginx is a webserver, used mostly as a reverse proxy 
# TODO : regroup all of the nginx settings here and add 
# a simple option to proxy addresses
{ config, lib, ... }:
let
  cfg = config.nixos.server.proxy.nginx;
in
{
  options.nixos.server.proxy.nginx = with lib; {
    proxies =  mkOption {
      description = "list of proxies to add to nginx"; 
      default = null;
      type = with types; nullOr (nonEmptyListOf (
        submodule {
                options = {
                  host = mkOption {type = str; description = "hostname to reverse proxy"; };
                  port = mkOption {type = int; description = "port to redirect to"; };
                  forceSSL = mkOption {type = bool; description "set to true to force SSL" default = false;};
                  protocol = mkOption {type = str; description = "protocol to use"; default = "http";};
                  address = mkOption {type = str; description = "IPv4 address"; default = "127.0.0.1";};
                };
            }
      ));
  };

  config = lib.mkIf (cfg.proxies != null) {

    # Use recommended settings
    services.nginx = {
      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;

      # add every virtualHosts :
      services.nginx.virtualHosts = listToAttrs (map (x: {
        name = x.host;
        value = rec {
          enableACME = config.security.acme.acceptTerms;
          addSSL = enableACME && !x.forceSSL;
          forceSSL = enableACME && x.forceSSL;
          locations."/" = {
          proxyPass = "${x.protocol}://${x.address}:${builtins.toString x.port}/";
          proxyWebsockets = true;
        };
        };
      }) cfg.proxies);
    };
    };
  };
}
