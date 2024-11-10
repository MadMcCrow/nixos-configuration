# cockpit.nix
#   configuration for the cockpit service container
{
  pkgs,
  lib,
  config,
  ...
}:
let
  port = 9090;
  cfg = config.nixos.server.services.cockpit;
in
{
  options.nixos.server.services.cockpit = with lib; {
    enable = mkEnableOption "cockpit, the simplest dashboard";
    subDomain = mkOption {
      description = "subdomain to use for the cockpit service";
      type = types.str;
      default = "cockpit";
    };
  };

  config = lib.mkIf cfg.enable {
    # our actual container :
    containers."cockpit" = {
      autoStart = true;
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      nixpkgs = pkgs.path;
      ephemeral = true;
      config =
        { ... }:
        {
          # cockpit (web-based server interface )
          services.cockpit = {
            enable = true;
            openFirewall = true;
            inherit port;
          };
          system.stateVersion = config.system.stateVersion;
        };
    };

    nixos.server.proxy.nginx.hosts = [
      {
        subDomain = cfg.subDomain;
        inherit port;
      }
    ];
  };
}
