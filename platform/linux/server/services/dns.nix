# dns.nix
#   configuration for the dnsmasq service container
{ config, pkgs, lib, ... }:
let
  cfg = config.nixos.server;
  serverIP = "127.0.0.1";
  domainName = "dns.${cfg.hostName}";
in {
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
}
