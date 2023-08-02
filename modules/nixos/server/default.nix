# server/default.nix
# 	each server service is enabled in a separate sub-module
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # shortcut
  cfg = config.nixos.server;

  # helper functions
  mkEnableOptionDefault = description: default:
    (mkEnableOption description) // {
      inherit default;
    };
  mkStringOption = description: default:
    mkOption {
      inherit default description;
      type = types.str;
    };

  # make a valid host name with prefix and suffix.
  subHostName = sub: concatStringsSep "/" [ cfg.hostName sub ];

  # maybe it won´t fail if we don't check for it !
  nextcloudSecretPath = config.secrets.secretsPath + "nextcloud.age";
  nextcloudEnable = cfg.nextcloud.enable && pathExists nextcloudSecretPath;

in {

  # interface
  options.nixos.server = {
    enable = mkEnableOptionDefault "server services" false;
    hostName = mkStringOption "server host name" "localhost";
    cockpit.enable = mkEnableOptionDefault "cockpit web-based interface" true;
    seafile.enable = mkEnableOptionDefault "seafile file manager" true;
    data.path = mkStringOption "path to store data for the server"
      "/persist/database/data";
    nextcloud = {
      enable = mkEnableOptionDefault "nextcloud" true;
      package = mkOption {
        description = "nextcloud package";
        default = pkgs.nextcloud27;
      };
      hostName = mkStringOption "host name for nextcloud" "nextcloud";
      onlyOffice = {
        enable = mkEnableOptionDefault "only office nextcloud integration" true;
        documentServer =
          mkStringOption "hostname for document server" "only-office";
      };
    };
  };

  # server configuration
  config = mkIf cfg.enable {

    # our secrets option
    secrets.secrets = [{ name = "nextcloud"; }];

    # cockpit (web-based server interface )
    services.cockpit = mkIf cfg.cockpit.enable {
      enable = true;
      openFirewall = true;
      port = 9090;
    };

    #seafile
    #services.seafile = mkIf cfg.seafile.enable {
    #  adminEmail = "noe.perard+seafile@gmail.com";
    #  enable = true;
    #   };

    # serve nix store over ssh
    nix.sshServe.enable = true;

    services.openssh = {
      enable = true;
      # require public key authentication for better security
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
      };
      #permitRootLogin = "yes";
    };

    # nginx host for enforcing ssl
    services.nginx.virtualHosts."${cfg.hostName}" = {
      addSSL = true;
      enableACME = true;
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "noe.perard@gmail.com";
    };

    # DTBs : postgresql is faster
    services.postgresql = {
      enable = true;
      dataDir = concatStringsSep "/" [ cfg.data.path "postgresql" ];
      # No need to ensure databases
      #ensureDatabases = [ "nextcloud" ];
      #ensureUsers = [{
      #  name = "nextcloud";
      #  ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      #}];
    };
    # auto-backup
    #services.postgresqlBackup = {
    #  enable = false;
    #  location = ""; # find a way to have a network location or another drive
    #};

    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };

    # nextcloud and its apps (defined at nextcloud-apps.nix)
    services.nextcloud = mkIf nextcloudEnable {
      enable = true;
      package = cfg.nextcloud.package;
      hostName = subHostName cfg.nextcloud.hostName;
      config = {
        adminuser = "admin";
        adminpassFile = nextcloudSecret.path ;
        overwriteProtocol = "https";
        dbtype = "pgsql"; # hopefully dtb  is created on the correct data path
        # not necessary thanks to createLocally
        #dbuser = "nextcloud";
        #dbname = "nextcloud";
        #dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
        #dbpassFile = config.age.secrets.postgresql-nc.path;
      };
      database.createLocally =
        true; # only one computer, ask to generate all dtb settings
      https = true;
      extraAppsEnable = true;
      extraApps = import ./nextcloud-apps.nix { inherit pkgs; };
    };

    # TODO : switch to collabora
    services.onlyoffice = {
      enable = true;
      hostname = subHostName cfg.nextcloud.onlyOffice.documentServer;
    };

    # probably due to only-office (Microsoft fonts)
    packages.unfreePackages = [ "corefonts" ];

  };
}
