# Jellyfin
# TODO : configure everything !!!
{ lib, config, ... }:
let
  # shortcut
  inherit (config.nixos) web;
in
{
  # interface
  options.nixos.web.jellyfin = with lib; {
    enable = mkEnableOption "jellyfin server" // {
      default = web.media.enable;
    };
    subDomain = mkOption {
      description = "subdomain for jellyfin service";
      type = with types; nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+)" s) != null));
      default = "jellyfin";
    };
  };

  #implementation
  config = lib.mkIf web.jellyfin.enable {
    nixos.web.services.jellyfin = {
      dataPath = "/www/jellyfin";
      config = {
        services.jellyfin = {
          enable = true;
        };
      };
    };
  };
}
