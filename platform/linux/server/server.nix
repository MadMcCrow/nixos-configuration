{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixos.server;
in
{
  # interface
  options.nixos.server = with lib; {
    enable = mkEnableOption "server services and packages";
    # Domain Name for the services
    domainName = mkOption {
      description = "a domain name for all the hosted services";
      type = with types; nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+.[a-z]+)" s) != null));
      example = "cool-domain.com";
      default = config.networking.domain;
    };
    # email
    adminEmail = mkOption {
      description = "email to contact in case of problem";
      type = with types; nullOr (addCheck str (s: (builtins.match "([a-z0-9+.]+@[a-z0-9.]+)" s) != null));
      example = "admin@server.net";
    };

    containerBridge = {
      enable = mkEnableOption "host bridge for nixos containers";
      name = mkOption {
        description = "bridge name to use";
        type = types.string;
        default = "br0";
      };
      interface = mkOption {
        description = "bridge interface to use";
        type = types.string;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # let's have ping
    environment.systemPackages = [ pkgs.inetutils ];
    # let's encrypt certificate
    security.acme = {
      acceptTerms = true;
      defaults.email = cfg.adminEmail;
    };

    # nginx reverse proxy :
    services.nginx = {
      enable = true;
      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    networking = lib.mkIf cfg.containerBridge.enable {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = "ens3";
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };
      bridges."${cfg.containerBridge.name}".interfaces = [ cfg.containerBridge.interface ];
      interfaces."${cfg.containerBridge.name}".useDHCP = true;
    };

    # make all containers use the bridge
    # containers = builtins.mapAttrs (name: value:
    #   value // (lib.mkIf cfg.containerBridge.enable {
    #     privateNetwork = lib.mkForce true;
    #     hostBridge = cfg.containerBridge.name;
    #   })) config.containers;
  };
}
