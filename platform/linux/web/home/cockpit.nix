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
  options.nixos.web.home.cockpit = with lib; {
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
        { _ }:
        {
          # cockpit (web-based server interface )
          services.cockpit = {
            enable = true;
            openFirewall = true;
            inherit port;
          };
          users.users = lib.attrsets.filterAttrs (n: v: v.isNormalUser) config.users.users;
          programs.zsh = config.programs.zsh; # some users might need it
          system.stateVersion = config.system.stateVersion;
        };
    };

    nixos.server.proxy.nginx.virtualHosts = [
      {
        inherit (cfg) subDomain;
        inherit port;
      }
    ];
  };
}
