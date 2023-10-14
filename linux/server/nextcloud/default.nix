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
  srv = config.nixos.server;
  cfg = srv.nextcloud;

  mkPath = l: concatStringsSep "/" l;

  # path to our data
  nextcloudPath = mkPath [config.nixos.server.data.path "nextcloud"];

  # make sure nextcloud can be instantiated
  nextcloudSecret =config.age.secrets."nextcloud".path;
  nextcloudEnable = config.secrets.enable && cfg.enable;

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
    systemd.services."nextcloud-setup" = let
      secret-service = config.secrets.updateSecretsPackage.pname;
    in {
         requires = [ "${secret-service}.service" ];
         after = [ "${secret-service}.service" ];
    };

    # nextcloud user
    users.users.nextcloud.uid = lib.mkForce 115;
    users.groups.nextcloud.gid = lib.mkForce 121;
    users.users.nextcloud.group = "nextcloud";
    users.users.nextcloud.extraGroups = [ "ssl-cert" ];

    # ensure data folder
    systemd.tmpfiles.rules = [
      "d ${nextcloudPath} 0750 nextcloud nextcloud -"
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
        adminpassFile = nextcloudSecret ;
        #overwriteProtocol = "https";
      };
      # for now forget about safety
      https = false;
    };
  };
}
