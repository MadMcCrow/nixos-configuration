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
      example = "/run/persist/serverdata/nextcloud";
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

      config = { ... } : {
        # import the nextcloud service configuration
        imports = [ ./nc.nix ./apps.nix ];

        # TODO : move to all containers !
        config = {
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

    # add it to /etc/hosts
    # networking.hosts = {
    #   "127.0.0.1" = [ hostName ];
    #   #     "::1" = "nextcloud.${config.networking.domain}";
    # };

    # open firewall for passthrough on host
    # networking.firewall = {
    #   enable = true;
    #   allowedTCPPorts = [ 80 443 8080 8443];
    # };

  };
}
