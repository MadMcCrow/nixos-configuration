# container.nix
# Changes to the host system to have a nextcloud container
{ config, lib, pkgs, ... }:
let
  # shortcut
  cfg = config.nixos.server.services.nextcloud;
  hostName = "nextcloud";
in {

  # interface
  options.nixos.server.services.nextcloud = with lib; {
    enable = mkEnableOption "nextcloud instance";
    dataDir = mkOption {
      description = "path to the nextcloud storage folder";
      type = types.path;
      example = "/www/nextcloud";
    };

    subDomain = mkOption {
      description = "subdomain to use for nextcloud service";
      type = with types;
        nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+)" s) != null));
      default = "nextcloud";
    };
  };

  # implementation
  config = lib.mkIf cfg.enable {

    # our actual container :
    containers."nextcloud" = {

      # start at boot :
      autoStart = true;

      # container networking :
      # TODO : use bindings instead of host networking
      privateNetwork = false;

      # use host nix-store and nixpkgs config
      nixpkgs = pkgs.path;

      # do not store anything : the important data is backed on disk
      ephemeral = true;

      # mount the nextcloud data (the rest is ephemeral and gets recreated)
      bindMounts = {
        "/www/nextcloud" = {
          hostPath = "${cfg.dataDir}";
          isReadOnly = false;
        };
      };

      config = { ... }: {
        # import the nextcloud service configuration
        imports = [ ./nc.nix ./apps.nix ];

        # TODO : move to all containers !
        config = {
          # set nextcloud settings
          nc.hostName = "${cfg.subDomain}.${config.nixos.server.domainName}";
          # import the let's encrypt certificate from host
          security.acme = {
            inherit (config.security.acme) acceptTerms defaults;
          };

          networking.domain = config.networking.domain;
          networking.useHostResolvConf = true;
          system.stateVersion = config.system.stateVersion;
        };
      };
    };

    # make sure the dataDir exists on Host
    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0755 root root -" ];

    # delay container start to bindMount creation :
    systemd.services."container@nextcloud" = {
      wants = [ "systemd-tmpfiles-setup.service" ];
      after = [ "systemd-tmpfiles-setup.service" ];
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 8080 8443 ];
    };

    # nextcloud module is supposed to do the reverse proxy-ing itself.
    #services.nginx.enable = true;
    #services.nginx.virtualHosts."${cfg.subDomain}.${config.nixos.server.domainName}" = rec {
    #  enableACME = config.security.acme.acceptTerms;
    #  addSSL = enableACME;
    #  # forceSSL = enableACME;
    #  locations."/" = {
    #    proxyPass = "http://127.0.0.1:${builtins.toString http}/";
    #    # proxyWebsockets = true;
    #  };
    #};

  };
}
