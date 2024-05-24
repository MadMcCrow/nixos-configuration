# linux/server/nextcloud/nc.nix
# base nextcloud config.
{ pkgs, config, lib, ... }: {
  # interface:
  options.nc = with lib; {
    dataDir = mkOption {
      type = types.str;
      default = "/www/nextcloud";
    };
    hostName = mkOption {
      type = types.str;
      default = "nextcloud.${config.networking.domain}";
    };
  };

  config = {

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 8080 8443 ];
    };

    # Actual Nextcloud Config
    services.nextcloud = {
      enable = true;

      # upgrade manually here !
      package = pkgs.nextcloud28;

      # where to store the data
      home = "${config.nc.dataDir}/nc-data";

      # maybe use "trusted_domains"
      inherit (config.nc) hostName;
      # hostName = config.nc.hostName;

      # Use HTTPS for links
      https = true;

      # enable caching with redis :
      # configureRedis = true;

      # apps :
      autoUpdateApps.enable = false;
      appstoreEnable = false;
      extraAppsEnable = false;

      # PHP extensions :
      # phpExtraExtensions = all : with all; [
      #   smbclient # for smb support in nextcloud
      # ];

      config = {
        # Further forces Nextcloud to use HTTPS
        # overwriteProtocol = "https";
        dbtype = "mysql";
        dbuser = "nextcloud";
        dbname = "nextcloud";
        # dbpassFile = "${dataDir}/nextcloud-db-pass";
        adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
        #adminpassFile = "${dataDir}/nextcloud-admin-pass";
        adminuser = "admin";
      };

      # config.php declaration : extraOptions for 23.11, settings for 24.05 and onward
      # see https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/config_sample_php_parameters.html
      extraOptions = {
        # addresses you can access:
        trusted_domains = [ "127.0.0.1" "localhost" config.nc.hostName ];
        # log :
        loglevel = 3; # only errors
        log_type = "file";
        logfile = "nextcloud.log";
        logdateformat = "Y-m-d::H:i:s";
        # don't embed documentation
        "knowledgebase.embedded" = false;
        # my logo replaces nextcloud logo
        logo_url = "https://avatars.githubusercontent.com/u/10871181";

        # we need a mail server
        mail_domain = config.networking.domain;
      };
    };

    services.mysql = {
      enable = true;
      dataDir = "${config.nc.dataDir}/mysql";
      package = pkgs.mariadb;
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [{
        name = "nextcloud";
        ensurePermissions = { "nextcloud.*" = "ALL PRIVILEGES"; };
      }];
    };

    # todo : modify this
    # PHP-FPM service configuration for Nextcloud
    # services.phpfpm.pools.nextcloud = {
    #   user = "nextcloud";
    #   group = "nextcloud";
    #   phpOptions = ''
    #     upload_max_filesize = 1G
    #     post_max_size = 1G
    #     memory_limit = 512M
    #     max_execution_time = 300
    #     date.timezone = "Europe/Paris"
    #   '';
    # };

    # TODO : backup
    # services.mysqlBackup.enable = false;

    # create folder for db
    systemd.tmpfiles.rules = [
      "d ${config.nc.dataDir}/mysql     0750 mysql         mysql         -"
      "d ${config.nc.dataDir}/nc-data   0750 nextcloud     nextcloud     -"
    ];

    systemd.services."mysql" = {
      wants = [ "systemd-tmpfiles-setup.service" ];
      after = [ "systemd-tmpfiles-setup.service" ];
    };

    # start nextcloud after tmpfiles and db is ready :
    systemd.services."nextcloud-setup" = {
      wants = [ "systemd-tmpfiles-setup.service" ];
      requires = [ "mysql.service" ];
      after = [ "mysql.service" "systemd-tmpfiles-setup.service" ];
    };
  };
}
