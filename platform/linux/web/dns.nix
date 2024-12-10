# dns.nix
#   configuration for the dnsmasq service container
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixos.server.services.dns;
in
{
  # interface
  options.nixos.server.services.dns = with lib; {
    enable = mkEnableOption "dns service";
    serverIP = mkOption {
      description = "server IP to listen to";
      type = types.string;
      default = "127.0.0.1";
    };
  };

  # implementation
  config.containers.dns = lib.mkIf cfg.enable {
    autoStart = true;
    privateNetwork = false;
    config =
      { pkgs, lib, ... }@args:
      {
        services.dnsmasq.settings = {
          port = "53";
          bogus-priv = true;
          listen-address = [
            "127.0.0.1"
            cfg.serverIP
          ];
          expand-hosts = true;
          domain = "dns.${config.networking.domain}";
          cache-size = "1000";
          domain-needed = true;
          # fallback servers
          server = [
            "8.8.8.8" # Google
            "8.8.4.4" # google backup
          ];
        };
        # default service networking :
        networking = {
          firewall.enable = true;
          firewall.allowedTCPPorts = [ 80 ];
          useHostResolvConf = lib.mkForce false;
        };
        services.resolved.enable = true;
        system.stateVersion = "23.11";
      };
  };
}
