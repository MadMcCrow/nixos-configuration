# server/default.nix
# 	each server service is enabled in a separate sub-module
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # shortcut
  cfg = config.nixos.server;

  # helper functions
  mkEnableOptionDefault = desc: default:
    mkEnableOption (mdDoc desc) // {
      inherit default;
    };
  mkStringOption = desc: default:
    mkOption {
      inherit default;
      type = types.str;
      description = mdDoc desc;
    };

  # make a valid host name with prefix and suffix.
  subHostName = sub : concatStringsSep "/" [cfg.hostName sub];

in {
  # interface
  options.nixos.server = {
    enable = mkEnableOptionDefault "server services" false;
    hostName = mkStringOption "server host name" "localhost";
    cockpit.enable = mkEnableOptionDefault "cockpit web-based interface" true;
    seafile.enable = mkEnableOptionDefault "seafile file manager" true;
    nextcloud = {
      package = mkOption {
        description = "nextcloud package";
        default = pkgs.nextcloud27;
      };
      enable = mkEnableOptionDefault "nextcloud" true;
      hostName = mkStringOption "host name for nextcloud" "nextcloud";
      onlyOffice = {
        enable = mkEnableOptionDefault "only office nextcloud integration" true;
        documentServer = mkStringOption "host name for only office document server" "only-office";

      };
    };
  };

  config = mkIf cfg.enable {
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

    # Ensure the database, user, and permissions always exist
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
     { name = "nextcloud";
       ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
     }
    ];
};
systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
};

    # nextcloud and its apps (defined at nextcloud-apps.nix)
    services.nextcloud = {
      enable = cfg.nextcloud.enable;
      package = cfg.nextcloud.package;
      hostName = subHostName cfg.nextcloud.hostName;
      config = {
        adminuser = "admin";
        adminpassFile = config.age.secrets.nextcloud.path;
        overwriteProtocol = "https";
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
        dbname = "nextcloud";
        dbpassFile = "/var/nextcloud-db-pass";
      };
      # enable https :
      # nginx.enable = true; # not necessary anymore
      https = true;
      # apps :
      extraAppsEnable = true;
      extraApps = import ./nextcloud-apps.nix { inherit pkgs; };
    };

    # encrypt nextcloud password
    age.secrets.nextcloud = mkIf cfg.nextcloud.enable {
      file = ../../../secrets/nextcloud.age; # todo : point to origin of flake
      owner = "nextcloud";
      group = "nextcloud";
    };
    age.identityPaths =
      if cfg.nextcloud.enable then [ "/persist/nixos/secrets/nextcloud" ] else [ ];

    services.onlyoffice = {
      enable = true;
      hostname = subHostName cfg.nextcloud.onlyOffice.documentServer;
    };

    # probably due to only-office (Microsoft fonts)
    packages.unfreePackages = ["corefonts"];

  };
}
