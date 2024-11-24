# Authelia is a services for authentifying
{config, lib, ...} :
let
web = config.nixos.web;
port = 9091;
in
{
  options.nixos.web.authelia = with lib; {
    dataPath = mkOption {
      description = "path to the authelia storage folder";
      type = types.path;
      example = "/www/authelia";
    };
  };

  config = lib.mkIf web.auth.enable {
    nixos.containers."authelia" = {
      config = {
        inherit (web.authelia) dataPath;
        config = {
          services.authelia.instances.main = {
            settings = {
      theme = "dark";
      default_redirection_url = "https://example.com";
  
            server = {
              host = "127.0.0.1";
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

  };
  };
}