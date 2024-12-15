# container.nix
# Changes to the host system to have a nextcloud container
{ config, lib, ... }:
let
  # shortcut
  inherit (config.nixos) web;
  cfg = web.nextcloud;
in
{

  # interface
  options.nixos.web.nextcloud = with lib; {
    enable = mkEnableOption "nextcloud instance";
    dataDir = mkOption {
      description = "path to the nextcloud storage folder";
      type = types.path;
      example = "/www/nextcloud";
    };
    subDomain = mkOption {
      description = "subdomain to use for nextcloud service";
      type =
        with types;
        nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+)" s) != null));
      default = "nextcloud";
    };
  };

  # implementation
  config = lib.mkIf cfg.enable {

    nixos.web.services."nextcloud" = {
      dataPath = "/www/nextcloud";

      config = {
        # import the nextcloud service configuration
        imports = [
          ./nc.nix
          ./apps.nix
        ];

        config = {
          # set nextcloud settings
          nc.hostName = "${cfg.subDomain}.${config.nixos.server.domain}";
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

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        8080
        8443
      ];
    };

  };
}
