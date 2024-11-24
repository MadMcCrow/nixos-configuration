# nginx is a webserver, used mostly as a reverse proxy 
{ config, lib, ... }:
let
  # shortcuts
  cfg = config.nixos.server.proxy;

  # custom option for building proxies
  proxyOption = 
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

    # helper function
    mkDomain = opt: if (opt.absoluteDomain != null) 
                then opt.absoluteDomain else "${opt.subDomain}.${opt.domain}";

in
{
  options.nixos.server.proxy = with lib; {
    # list of host to redirect
    virtualHosts = mkOption {
      description = "list of proxies to add to nginx";
      default = null;
      type = types.nullOr (types.nonEmptyListOf (proxyOption));
    };
    # ACME certificate
    certificates = {
      enableACME = mkEnableOption "Lets Encrpyt certificates" // { default = true; };
      useHost = mkEnableOption "generate only one certificate" // { default = true; };
    };
    
  };

  config = lib.mkIf (cfg.virtualHosts != null) {
    # reverse proxy using nginx
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
          name = mkDomain x;
          value = with lib; mkMerge [
            {
              locations."/" = {
              proxyPass = "${x.protocol}://${x.address}:${builtins.toString x.port}/";
              proxyWebsockets = true;
            };
          }
           (attrsets.optionalAttrs (cfg.certificates.enableACME) {
              addSSL   = !x.forceSSL;
              forceSSL = x.forceSSL;
          })
          (attrsets.optionalAttrs (cfg.certificates.enableACME && cfg.certificates.useHost) {
              useACMEHost = config.nixos.server.domainName;
          })

          (attrsets.optionalAttrs (cfg.certificates.enableACME && !cfg.certificates.useHost) {
              enableACME = true;
          })
          ];
        }) cfg.virtualHosts
      );
    };

    # CA Certificates
    security.acme = {
      # accept lets encrypt terms and conditions
      acceptTerms = true;
      defaults.email = cfg.adminEmail;
      preliminarySelfsigned = true;
      # certs."${config.nixos.server.domainName}" = rec {
      # domain = config.nixos.server.domainName;
      # extraDomainNames = [ domain ] ++ (map mkDomain cfg.virtualHosts);
      # dnsProvider = "ovh";
      # group = config.services.nginx.group; # use ngninx group
    #};
    };

    # end of config  
  };
}
