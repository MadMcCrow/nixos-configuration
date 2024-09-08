# cockpit.nix
#   configuration for the cockpit service container
{ lib, ... }:
{
  # cockpit (web-based server interface )
  services.cockpit = lib.mkIf cfg.cockpit.enable {
    enable = true;
    openFirewall = true;
    port = 9090;
  };
}
