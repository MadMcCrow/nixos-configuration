# /linux/server/nextcloud/sql.nix
# Defines the DTB for nextcloud
#  TODO : enable backup
{ pkgs, lib, config, ... }:
with builtins;
let
  # shortcuts
  nxt = config.nixos.server.nextcloud;
  cfg = nxt.sql;

  # nextcloud recommends mariadb
  dbtypes = [ "mariadb" "mysql" "postgresql" ];
  db = cfg.db;

  # path to the data on the server
  mkDataDir = folder:
    concatStringsSep "/" [ config.nixos.server.data.path folder ];

  # todo : make it work :

  isPostgres = db == "postgresql";

  # helper functions
  condArg = c: s: d: if c then s else d;
  condAttrs = c: s: condArg c s { };
  condDBType = pgsql: mysql: condArg isPostgres pgsql mysql;

  # settings for nextcloud
  dbuser = condDBType "postgres" "mysql";
  dbtype = condDBType "pgsql" "mysql";
  dbservice = condDBType "postgresql.service" "mysql.service";

in {
  # easy to switch dtb type :
  options.nixos.server.nextcloud.sql = {
    db = lib.mkOption {
      description =
        lib.concatStringsSep "," [ desc "one of " (toString dbtypes) ];
      type = lib.types.enum dbtypes;
      default = elemAt dbtypes 0;
    };
  };

  # implementation
  config = lib.mkIf nxt.enable {

    # we still work in nextcloud container

      # db user :
      users.users."${dbuser}" = {
        group = "${dbuser}";
        extraGroups = [ "ssl-cert" ];
        isSystemUser = true;
      };
      # TODO : Postgres group already exist and has gid
      users.groups."${dbuser}" = { };

      # start nextcloud after db is ready :
      systemd.services."nextcloud-setup" = {
        requires = [ dbservice ];
        after = [ dbservice ];
      };

      # create folder for db
      systemd.tmpfiles.rules =
        [ "d ${mkDataDir dbtype} 0750 ${dbuser} ${dbuser} -" ];

      # systemd services :
      services = lib.mkMerge [
        {
          nextcloud.database.createLocally = true;
          nextcloud.config = { inherit dbtype; };
        }
        (condAttrs isPostgres {
          postgresql = mkIf isPostgres {
            enable = isPostgres;
            dataDir = mkDataDir dbtype;
          };
          # TODO : enable backup :
          postgresqlBackup.enable = false;
        })
        (condAttrs (!isPostgres) {
          mysql = lib.mkIf isPostgres {
            enable = true;
            dataDir = mkDataDir dbtype;
            user = dbuser;
            group = dbuser;
            package = if db == "mariadb" then pkgs.mariadb else pkgs.mysql80;
          };
          # TODO: enable backup :
          mysqlBackup.enable = false;
        })
      ];
  };
}
