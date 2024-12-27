# services/adguard.nix
# adguard home is a DNS / adblock service
# TODO :
#   - private network for container
#   - Only store relevant files on disk
{ config, lib, ... }:
let
  # shortcut
  inherit (config.nixos) web;
  inherit (web) dns;
  cfg = dns.adguard;
  # PORTS FOR THE CONTAINER :
  # 53   -> DNS
  # 3002 -> webadmin
  # 445  -> https webadmin
  ports = {
    dns = dns.port;
    http = 3002;
    https = 445;
  };
in
{
  # interface
  options.nixos.web.dns.adguard = with lib; {
    enable = mkEnableOption "adguard DNS" // {
      default = dns.implementation == "adguard";
    };

    dataDir = mkOption {
      description = "path to the adguardhome storage folder";
      type = types.path;
      default = "/www/adguardhome";
    };
  };

  # implementation
  config = lib.mkIf (cfg.enable && dns.enable) {

    # our actual container :
    nixos.web.services."adguard" = {
      dataDir = "${cfg.dataDir}";
      config = {
        services.adguardhome = {
          enable = true;
          # extra configuration is done in the web interface
          mutableSettings = true;
          # DHCP is done by my rooter
          allowDHCP = false;
          # opens firewall for web admin page
          openFirewall = true;
          # Set web interface port
          port = ports.http;
          settings = {
            # all adresses with port
            http.address = "0.0.0.0:${builtins.toString ports.http}";
            # set admin user :
            users = [
              {
                name = "admin";
                # nix-shell -p apacheHttpd --command "htpasswd -B -C 10 -n admin"
                password = "$2y$10$ZsBnFvFVBBYHPUEm4zkd7O.jkJZF4EDWcACxkxG4EZIb6RbtUowfO";
              }
            ];
            dns.upstream_dns = dns.upstreams;
            #filtering = {
            #  filtering_enabled = true;
            #  safe_search = {
            #    enabled = true;
            #    google = true;
            # };
            # not sure about this : 
            # rewrites = {
            #    domain = "*.{srv.domainName}";
            #    answer = "0.0.0.0";
            # };
            # TODO :
            #querylog.dir_path
            #statistics.dir_path
          };
        };

        # open firewall in the container :
        networking.firewall = {
          enable = true;
          allowedTCPPorts = builtins.attrValues ports;
          allowedUDPPorts = [ ports.dns ];
        };
      };
    };

    nixos.web.proxy.virtualHosts."${dns.subDomain}" = {
      port = ports.https;
      https = true;
    };

    # open firewall to access webadmin redirect and DNS server
    networking.firewall = {
      enable = true;
      allowedTCPPorts = builtins.attrValues ports;
      allowedUDPPorts = [ ports.dns ];
    };
  };
}
