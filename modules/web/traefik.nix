# Traefik is a dynamic reverse proxy
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixos.server.services.traefik;
in
{
  # interface
  options.nixos.server.services.traefik = with lib; {
    enable = mkEnableOption "traefik instance";
    dataDir = mkOption {
      description = "path to the traefik storage folder";
      type = types.path;
      example = "/www/traefik";
    };
  };

  config = lib.mkIf cfg.enable {

    # our actual container :
    containers."traefik" = {
      # start at boot :
      autoStart = true;
      # container networking :
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      # use host nix-store and nixpkgs config
      nixpkgs = pkgs.path;
      # do not store anything
      ephemeral = true;
      # mount storage path
      bindMounts = {
        "/www/traefik" = {
          hostPath = "${cfg.dataDir}";
          isReadOnly = false;
        };
      };

      config = _: {
        services.traefik = {
          enable = true;
          package = pkgs.traefik;
          dataDir = "/www/traefik";
          # todo :
          # staticConfigOptions
        };
        networking.domain = config.networking.domain;
        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
