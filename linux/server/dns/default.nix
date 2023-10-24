# server/dns/default.nix
# 	services for local DNS server
{ config, pkgs, lib, ... }:
with builtins;
let
  # shortcut
  srv = config.nixos.server;
  cfg = srv.dns;

  # helper functions
  mkEnableOptionDefault = description: default:
    (lib.mkEnableOption description) // {
      inherit default;
    };
  mkStringOption = description: default:
    lib.mkOption {
      inherit default description;
      type = lib.types.str;
    };

in {

  # interface
  options.nixos.server.dns = {
    enable = mkEnableOptionDefault "DNS" true;
    serverIP = mkStringOption "server IP" "127.0.0.1";
    domainName = mkStringOption "dns server name" "dns.${srv.hostName}";
  };

  config = lib.mkIf cfg.enable {
    services.dnsmasq.settings = {
      port = "53";
      bogus-priv = true;
      listen-address = [ "127.0.0.1" cfg.serverIP ];
      expand-hosts = true;
      domain = cfg.domainName;
      cache-size = "1000";
      domain-needed = true;
      # fallback servers
      server = [
        "8.8.8.8" # Google
        "8.8.4.4" # google backup
      ];
    };
  };
}
