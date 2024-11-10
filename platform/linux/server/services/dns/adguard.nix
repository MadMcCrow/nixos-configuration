# services/adguard.nix
# adguard home is a DNS / adblock service
# TODO :
#   - private network for container
#   - Only store relevant files on disk
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # shortcut
  srv = config.nixos.server;
  cfg = srv.services.adguard;
  # PORTS FOR THE CONTAINER :
  # 53   -> DNS
  # 3002 -> webadmin
  # 445  -> https webadmin
  dns = 53;
  http = 3002;
  https = 445;
in
{
  # interface
  options.nixos.server.services.adguard = with lib; {
    enable = mkEnableOption "adguard instance";
    dataDir = mkOption {
      description = "path to the adguardhome storage folder";
      type = types.path;
      example = "/www/adguardhome";
    };
    subDomain = mkOption {
      description = "subdomain to use for nextcloud service";
      type = with types; nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+)" s) != null));
      default = "nextcloud";
    };
  };

  # implementation
  config = lib.mkIf cfg.enable {
    # our actual container :
    containers."adguard" = {
      autoStart = true;
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      nixpkgs = pkgs.path;
      ephemeral = true;
      bindMounts = {
        "/" = {
          hostPath = "${cfg.dataDir}";
          isReadOnly = false;
        };
      };
      config =
        { ... }:
        {
          services.adguardhome = {
            enable = true;
            # extra configuration is done in the web interface
            mutableSettings = true;
            # DHCP is done by my rooter
            allowDHCP = false;
            # opens firewall for web admin page
            openFirewall = true;
            # Set web interface port
            port = http;
            settings = {
              # all adresses with port
              http.address = "0.0.0.0:${builtins.toString http}";
              # set admin user :
              users = [
                {
                  name = "admin";
                  # nix-shell -p apacheHttpd --command "htpasswd -B -C 10 -n admin"
                  password = "$2y$10$ZsBnFvFVBBYHPUEm4zkd7O.jkJZF4EDWcACxkxG4EZIb6RbtUowfO";
                }
              ];
              # cool upstream to avoid to retype at every reboot !
              dns.upstream_dns = [
                "# Open DNS (Cisco)"
                "208.67.222.222"
                "208.67.220.220"
                "208.67.222.220"
                "2620:119:35::35"
                "2620:119:53::53"
                "# Level3"
                "4.2.2.1"
                "4.2.2.2"
              ];
              #filtering = {
              #  filtering_enabled = true;
              #  safe_search = {
              #    enabled = true;
              #    google = true;
              # };
              # # not sure about this : 
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
            allowedTCPPorts = [
              dns
              http
              https
            ];
            allowedUDPPorts = [ dns ];
          };
          system.stateVersion = config.system.stateVersion;
        };
    };

    # redirect via reverse proxy :
    services.nginx.enable = true;
    services.nginx.virtualHosts."${cfg.subDomain}.${config.nixos.server.domainName}" = rec {
      enableACME = config.security.acme.acceptTerms;
      addSSL = enableACME;
      # forceSSL = enableACME;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString http}/";
        proxyWebsockets = true;
      };
    };

    # open firewall to access webadmin redirect and DNS server
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        dns
        80
        443
        http
        https
      ];
      allowedUDPPorts = [ dns ];
    };

    # make sure the dataDir exists on Host
    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0755 root root -" ];

    # delay container start to bindMount creation :
    systemd.services."container@adguard" = {
      wants = [ "systemd-tmpfiles-setup.service" ];
      after = [ "systemd-tmpfiles-setup.service" ];
    };
  };
}
