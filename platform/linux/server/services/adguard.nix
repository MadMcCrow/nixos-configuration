# services/adguard.nix
# adguard home is a DNS / adblock service
# TODO :
#   - private network for container
#   - port forwarding for container
#   -
{ config, lib, pkgs, ... }:
let
# shortcut
cfg = config.nixos.server.services.adguard;
# PORTS :
# 53   -> DNS
# 3002 -> webadmin
# 445  -> https webadmin
dns = 53;
http = 3002;
https = 445;
in {
  # interface
  options.nixos.server.services.adguard = with lib; {
    enable = mkEnableOption "adguard instance";
    dataDir = mkOption {
      description = "path to the adguardhome storage folder";
      type = types.path;
      example = "/www/adguardhome";
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
      # "/var/lib/AdGuardHome" = {
      #     hostPath = "${cfg.dataDir}/public";
      #     isReadOnly = false;
      #   };
      # "/var/lib/private/AdGuardHome" = {
      #     hostPath = "${cfg.dataDir}/private";
      #     isReadOnly = false;
      #   };
      };
      config = { ... }:
      {
        services.adguardhome = {
          enable = true;
          # extra configuration is done in the web interface
          mutableSettings = true;
          # DHCP is done by my rooter
          allowDHCP = false;
          # Set web interface port
          settings.bind_port = http;
          settings.http.address = "0.0.0.0:${builtins.toString http}";
          # opens firewall for web admin page
          openFirewall = true;
          settings.users = [ {
              name = "admin";
              # nix-shell -p apacheHttpd --command "htpasswd -B -C 10 -n admin"
              password = "$2y$10$ZsBnFvFVBBYHPUEm4zkd7O.jkJZF4EDWcACxkxG4EZIb6RbtUowfO";
            } ];
        };

        # open firewall
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ dns http https ];
          allowedUDPPorts = [ dns ];
        };
        networking.domain = config.networking.domain;
        system.stateVersion = config.system.stateVersion;
      };
    };

    # open firewall to access container
    networking.firewall = {
          enable = true;
          allowedTCPPorts = [ dns http https ];
          allowedUDPPorts = [ dns ];
        };

    # make sure the dataDir exists on Host
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}            0755 root root -"
      #"d ${cfg.dataDir}/public     0755 root root -"
      #"d ${cfg.dataDir}/private    0755 root root -"
      ];

    # delay container start to bindMount creation :
    systemd.services."container@adguard" = {
      wants = [ "systemd-tmpfiles-setup.service" ];
      after = [ "systemd-tmpfiles-setup.service" ];
    };

  };
}
