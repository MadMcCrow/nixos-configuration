# server/default.nix
# 	each server service is enabled in a separate sub-module
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # shortcut
  cfg = config.nixos.server;

  # helper function
  mkEnableOptionDefault = desc: default:
    mkEnableOption (mdDoc desc) // {
      inherit default;
    };
  mkStringOption = desc : default: mkOption {inherit default; type = types.str; description = mdDoc desc;};



  # TODO : somehow move this higher
  mkSubHostNames = pre : host : page: concatStringsSep "/" [(concatStringsSep "."  (filter (x: x != "") [pre host])) page];

in {
  # interface
  options.nixos.server = {
    enable = mkEnableOptionDefault "server services" false;
    hostname = mkStringOption "server host name" "localhost";
    cockpit.enable = mkEnableOptionDefault "cockpit web-based interface" true;
    seafile.enable = mkEnableOptionDefault "seafile file manager" true;
    nextcloud = {
      package = mkOption {description = "nextcloud package"; default = pkgs.nextcloud27;};
      enable = mkEnableOptionDefault "nextcloud" true;
      hostname = mkStringOption "host name for nextcloud" (mkSubHostNames "" cfg.hostname "nextcloud");
      onlyOffice = {
        enable = mkEnableOptionDefault "only office nextcloud integration" true;
        documentServer =  mkStringOption "host name for only office document server" (mkSubHostNames "" cfg.hostname "only_office");
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
  services.nginx.virtualHosts.${cfg.nextcloud.hostname} = {
    forceSSL = true;
    enableACME = true;
  };

    # DTBs : mysql
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

    # nextcloud and its apps (defined at nextcloud-apps.nix)
    #services.nextcloud = {
    #  enable = cfg.nextcloud.enable;
    #  package = cfg.nextcloud.package;
    #  hostName = cfg.nextcloud.hostname;
    #  config = {
    #    adminuser = "admin";
    #    adminpassFile = config.age.secrets.nextcloud.path;
    #  };
    #  # enable https :
    #  https = true;
    #  # apps :
    #  extraAppsEnable = true;
    #  extraApps = import ./nextcloud-apps.nix {inherit pkgs;};
    #};

    # encrypt nextcloud password
    #age.secrets.nextcloud = mkIf cfg.nextcloud.enable {
    #  file = ../../../secrets/nextcloud.age; # todo : point to origin of flake
    #  owner = "nextcloud";
    #  group = "nextcloud";
    #};
    #age.identityPaths = if cfg.nextcloud.enable then ["/persist/secrets/nextcloud"] else [];

    #services.onlyoffice = {
    #  enable = true;
    #  hostname = cfg.nextcloud.onlyOffice.documentServer;
    #};

    #security.acme.acceptTerms = true;
  };
}
