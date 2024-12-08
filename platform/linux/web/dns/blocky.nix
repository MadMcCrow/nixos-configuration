# TODO:
# https://nixos.wiki/wiki/Blocky
{ lib, config, ... }:
let
  inherit (config.nixos) web;
  inherit (web) dns;
  cfg = dns.blocky;
in
{
  options.nixos.web.dns.blocky = with lib; {

    # maybe get rid of this option
    enable = mkEnableOption "blocky DNS" // {
      default = dns.implementation == "blocky";
    };

    dataDir = mkOption {
      type = types.path;
      description = "path to the blocky data";
      default = "/www/blocky";
    };
  };

  # implementation
  config = lib.mkIf (cfg.enable && dns.enable) {
    nixos.web.services."blocky" = {
      dataPath = "${cfg.dataDir}";
      config = {
        services.blocky.enable = true;
        # use https://0xerr0r.github.io/blocky/latest/configuration/
        services.blocky.settings = {
          ports = {
            dns = dns.port;
            # tls = ?? 
            # http = 3002;
            https = 445;
          };

          upstreams = {
            groups = {
              "default" = dns.upstreams;
              # you can use subnets here to only use certain upstreams
            };
            timeout = "0.5s";
            strategy = "random"; # better for privacy
          };
          customDNS = {
            #customTTL: 1h
            #filterUnmappedTypes: true # default !
            #rewrite = {
            #  "${web.domain}" = "home";
            #  "home" = "lan";
            #};
            mapping = {
              "${web.domain}" = "127.0.0.1"; # maybe use localhost ?
              #printer.lan: 192.168.178.3
              #otherdevice.lan: 192.168.178.15,2001:0db8:85a3:08d3:1319:8a2e:0370:7344
            };
          };
        };
      };
    };
  };
}
