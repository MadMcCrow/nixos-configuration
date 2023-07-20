# secrets/default.nix
#   module for adding our secrets to the configurations
{ config, lib, agenix, ... }:
with builtins;
with lib;
let
  # shortcut
  cfg = config.secrets;
  # wrapped function
  mkEnableOptionDefault = desc : default: (mkEnableOption (mdDoc desc)) // { inherit default;};

  hostKey = concatStringsSep "/" [cfg.keyPath config.networking.hostName];

in
{
  options.secrets = {
    enable = mkEnableOptionDefault "secret management with age" false;
    keyPath = mkOption {description = "path to all keys"; default="/persist/secrets";};
    # TODO : replace with generic secrets !(ie a function to build a secret based on a name only)
    nextcloud  =  mkEnableOptionDefault "nextcloud.age secret" false;
    postgresql-nc =  mkEnableOptionDefault "postgresql.age secret" false;
  };

  config = mkIf cfg.enable {
    age = {
      secrets.nextcloud = mkIf cfg.nextcloud {
      file = ./nextcloud.age;
      owner = "nextcloud";
      group = "nextcloud";
      };
      #secrets.postgresql-nc = mkIf cfg.postgresql-nc {
      #file = ./postgresql-nc.age;
      #owner = "nextcloud";
      #group = "nextcloud";
      #};
      identityPaths = [ hostKey ];
    };
  };
}
