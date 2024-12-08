# nginx is a webserver, used mostly as a reverse proxy 
{ config, lib, ... }:
let
  # shortcuts
  inherit (config.nixos) web;
  cfg = web.proxy;

  # custom option for building proxies
  virtualHostOption =
    with lib;
    with lib.types;
    submodule {
      options = {
        subDomain = mkOption {
          type = nullOr str;
          description = "subdomain to reverse proxy";
          default = null;
        };
        port = mkOption {
          type = int;
          description = "port to redirect to";
        };
        https = mkOption {
          type = bool;
          description = "serve as https";
          default = true;
        };
      };
    };
in
{
  options.nixos.web.proxy = with lib; {
    # list of host to redirect
    virtualHosts = mkOption {
      description = "list of proxies to add to nginx";
      default = { };
      type = types.attrsOf virtualHostOption;
    };
    # ACME certificate
    certificates = {
      enableACME = mkEnableOption "Lets Encrpyt certificates" // {
        default = true;
      };
      useHost = mkEnableOption "generate only one certificate" // {
        default = true;
      };
    };

  };

  config = lib.mkIf web.enable {
    # reverse proxy using nginx
    services.nginx = {
      enable = true;
      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # redirect home :
      virtualHosts =
        {
          "${web.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              # redirect to home (this might redirect then to auth)
              return = "301 ${web.home.subDomain}.${web.domain}";
            };
          };
        }
        # other redirections : 
        // (
          with builtins;
          listToAttrs (
            map (name: {
              # attrName
              name = "${name}.${web.domain}";
              # attrValue
              value =
                let
                  value = cfg.virtualHosts."${name}";
                in
                {
                  useACMEHost = "${web.domain}";
                  forceSSL = value.https;
                  locations."/" = {
                    proxyPass = "http://localhost:${toString value.port}";
                    proxyWebsockets = true;
                  };
                };
            }) (attrNames cfg.virtualHosts)
          )
        );

      # end of nginx setup
    };

    # Authentification support
    services.oauth2-proxy = {
      enable = true;
      provider = "keycloak-oidc"; # maybe try "oidc" next
      oidcIssuerUrl = "${web.auth.subDomain}.${web.domain}";
    };

    # CA Certificates
    security.acme = {
      # accept lets encrypt terms and conditions
      acceptTerms = true;
      defaults.email = web.adminEmail;
      preliminarySelfsigned = true;
      # default cert created by "enableACME";
      certs."${web.domain}" = {
        extraDomainNames =
          # all the subdomain from virtual hosts 
          map (x: "${x}.${web.domain}") (builtins.attrNames cfg.virtualHosts)
          # add home domain name to cert
          ++ [ "${web.home.subDomain}.${web.domain}" ];
      };
    };
    # end of config  
  };

}
