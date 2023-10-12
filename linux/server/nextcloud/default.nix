# linux/server/nextcloud/default.nix
#   all that is necessary for getting nextcloud to work OOTB
#   TODO:
#         - Enable HTTPS
#         - Remote access (ie from outside of my local network)
{ pkgs, config, lib, ... } :
with builtins;
with lib;
let
  # shortcuts
  srv = config.linux.server;
  cfg = srv.nextcloud;

  # path to our data 
  nextcloudPath = concatStringsSep "/" [config.nixos.server.data.path "nextcloud"];

  # make sure nextcloud can be instantiated
  nextcloudSecretPath = config.secrets.secretsPath + "nextcloud.age";
  nextcloudEnable = if (strings.hasPrefix "/" config.secrets.secretsPath) 
  && pathExists nextcloudSecretPath then cfg.enable else false;

in
{
  # interface:
  options.nixos.server.nextcloud = {
    enable = mkEnableOption "nextcloud" // { default = true; };
    hostName = mkOption {
      default = "nextcloud.${srv.hostName}";
      description = "hostname for nextcloud instance";
      type = types.str;
    };
  };

  # sub-modules
  imports = [ ./sql.nix ./apps.nix ];

  # config
  config = mkIf nextcloudEnable {

    # our secrets for password
    # this gets generated with nixos-update-age-secrets
    secrets.secrets = [{ name = "nextcloud"; }];

    # nextcloud user
    users.users.nextcloud.uid = lib.mkForce 115;
    users.groups.nextcloud.gid = lib.mkForce 121;
    users.users.nextcloud.group = "nextcloud";
    users.users.nextcloud.extraGroups = [ "ssl-cert" ];

    # ensure data folder
    systemd.tmpfiles.rules = [
      "d ${nextcloudPath} 0770 nextcloud nextcloud -"
    ];

    # setup SSL and ACME for https :
    # services.nginx.virtualHosts.${cfg.hostName} = {
    #   forceSSL = true;
    #   enableACME = true;
    # };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud27;
      hostName = cfg.hostName;
      datadir = nextcloudPath;
      config = {
        adminuser = "admin";
        adminpassFile = nextcloudSecretPath ;
        #overwriteProtocol = "https";
      };   
      # for now forget about safety
      https = false;
    };
  };
}