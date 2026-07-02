# Authelia is a services for authentifying
{ config, lib, ... }:
let
  inherit (config.nixos) web;
  port = 9091;
in
{
  options.nixos.web.auth.authelia = with lib; {
    dataPath = mkOption {
      description = "path to the authelia storage folder";
      type = types.path;
      default = "/www/authelia";
    };
  };

  config = lib.mkIf web.enable {
    nixos.web.containers."authelia" = {
      config = _: {
        inherit (web.authelia) dataPath;
        config = {
          services.authelia.instances.main = {
            settings = {
              theme = "dark";
              server = {
                host = "127.0.0.1"; # maybe use localhost ?
                inherit port;
              };
              log = {
                level = "debug";
                format = "text";
              };
            };
          };
        };
      };
    };

    nixos.web.proxy."authelia" = {
      inherit port;
      inherit (config.nixos.web.auth) subDomain;
    };
  };
}
