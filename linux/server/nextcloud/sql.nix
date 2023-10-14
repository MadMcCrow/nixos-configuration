# /linux/server/nextcloud/sql.nix
# Defines the DTB for nextcloud
#  TODO : enable backup
{ pkgs, lib, config, ... }:
with builtins;
with lib;
let
  # shortcuts
  nxt = config.nixos.server.nextcloud;
  cfg = nxt.sql;

  # path to the data on the server
  postgresPath = concatStringsSep "/" [config.nixos.server.data.path "postgresql"];
in
{
   # implementation
   config = mkIf nxt.enable {
      # force nextcloud to use postgresql
      services.nextcloud = {
         config.dbtype = "pgsql";
         database.createLocally = true;
      };

      # make sure postgresql starts first
      systemd.services."nextcloud-setup" = {
         requires = [ "postgresql.service" ];
         after = [ "postgresql.service" ];
      };

      # perhaps make it share group with nextcloud ?
      users.users.postgres.uid = lib.mkForce 114;
      users.groups.postgres.gid = lib.mkForce 120;
      users.users.postgres.group = "postgres";
      users.users.postgres.extraGroups = [ "ssl-cert" ];

      # add postgres folder path
      systemd.tmpfiles.rules= [ "d ${postgresPath} 0750 postgres  postgres -" ];

      # set folder for postgresql
      services.postgresql = {
         enable = true;
         dataDir = postgresPath;
      };

      #services.postgresqlBackup = {
      #  enable = false;
      #  location = ""; # find a way to have a network location or another drive
      #};
   };
}
