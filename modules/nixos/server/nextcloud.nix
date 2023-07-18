# server/nextcloud.nix
# 	nextcloud and all it's apps
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.nixos.server;
  # nextcloud does not get updated in the branch but with a new pkg
  nextcloudPkg = pkgs.nextcloud27;

  # TODO : check if we can just get without the release download
  cospend = pkgs.fetchNextcloudApp {
    name = "cospend";
    sha256 = "03bf11c44173ac43f1149b7d0cdbb921c8fab39e3e0627e4e8d7f5583b6bc181";
    url = "https://github.com/julien-nc/cospend-nc/releases/download/v1.5.10/cospend-1.5.10.tar.gz";
    version = "1.5.10";
  };

  onlyOffice = pkgs.fetchNextcloudApp {
    name = "onlyOffice-nc";
    sha256 = "e2fccfecf20b3821e039c5107b3fc578f70f54e3409c002b37c1c50149bcc0d2";
    url = "https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v8.1.0/onlyoffice.tar.gz";
    version = "1.5.10";
  };

  # TODO : somehow move this higher
  mkSubHostNames = pre : host : page: concatStringsSep "/" [(concatStringsSep "."  (filter (x: x != "") [pre host])) page];

  onlyOfficeHost = mkSubHostNames "" cfg.hostname "onlyOffice";
  nextcloudHost  = mkSubHostNames "" cfg.hostname "nextcloud";
in
{
options.nixos.server.nextcloud.enable = mkEnableOption (mdDoc "nextcloud") // {default = true;};

  config = kIf cfg.nextcloud.enable {

  # nginx host for enforcing ssl
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
  };

    # DTB
    services.mysql = {
        enable = true;
        package = pkgs.mysql;
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [
          {
            name = "nextcloud";
            ensurePermissions = {
              "nextcloud.*" = "ALL PRIVILEGES";
            };
          }
        ];
    };

    services.nextcloud = {
      enable = true;
      package = nextcloudPkg;
      hostName = nextcloudHost;
      config = {
        adminuser = "admin";
        adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
      };
      # enable https :
      https = true;
      # apps :
      extraAppsEnable = true;
      extraApps = { inherit cospend onlyOffice;};
    };

    services.onlyoffice = {
      enable = true;
      hostname = onlyOfficeHost;
  };

  };

}
