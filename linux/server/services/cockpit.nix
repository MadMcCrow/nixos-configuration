# cockpit.nix
#   configuration for the cockpit service container
{ config, pkgs, lib, ... }: {
  # cockpit (web-based server interface )
  services.cockpit = mkIf cfg.cockpit.enable {
    enable = true;
    openFirewall = true;
    port = 9090;
  };
}
