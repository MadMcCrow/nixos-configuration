# linux/server/nextcloud/default.nix
#   all that is necessary for getting nextcloud to work OOTB
#   TODO:
#         - Enable HTTPS
#         - Remote access (ie from outside of my local network)
{ pkgs, config, lib, ... }:
with builtins;
let
  # shortcuts
  srv = config.nixos.server;
  cfg = srv.nextcloud;

  # helper function
  condArg = n: s : d: if hasAttr n s then getAttr n s else d;

  mkPath = l: lib.concatStringsSep "/" l;

  # path to our data
  nextcloudPath = mkPath [ config.nixos.server.data.path "nextcloud" ];

  # make sure nextcloud can be instantiated
  secretDir = "${config.secrets.secretsPath}";
  nextcloudSecret = "${secretDir}/nextcloud.age";
  # can nextcloud work :
  nextcloudEnable = true;# pathExists secretDir;

in {
  # interface:
  options.nixos.server.nextcloud = {
    enable = lib.mkEnableOption "nextcloud" // { default = true; };
    hostName = lib.mkOption {
      default = "nextcloud.${srv.hostName}";
      description = "hostname for nextcloud instance";
      type = lib.types.str;
    };
  };

  # sub-modules
  imports = [ ./sql.nix ./apps.nix ];

  # config
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # our secrets for password
      # this gets generated with nixos-update-secrets
      secrets.secrets = [{ name = "nextcloud"; path = nextcloudSecret;}];

      # force updating secrets before initialisations :
      systemd.services."nextcloud-setup" = {
         requires = [ "${config.secrets.update.pname}.service" ];
         after = [ "${config.secrets.update.pname}.service" ];
      };
    }

  # if nextcloud can be enabled then do it:
  (lib.optionalAttrs nextcloudEnable {


    # nextcloud user
    # users.users.nextcloud.uid = lib.mkForce 115;
    # users.groups.nextcloud.gid = lib.mkForce 121;
    users.users.nextcloud.group = "nextcloud";
    users.users.nextcloud.extraGroups = [ "ssl-cert" ];

    # ensure data folder
    systemd.tmpfiles.rules = [ "d ${nextcloudPath} 0750 nextcloud nextcloud -" ];

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
        adminpassFile = nextcloudSecret;
        #overwriteProtocol = "https";
      };
      # for now forget about safety
      https = false;

      # image preview options :
      extraOptions.enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
      ];
    };
  })
  (lib.optionalAttrs (!nextcloudEnable) {
    # if we fail to meet requirements for service,
    # create user anyway
    users.users.nextcloud.group = "nextcloud";
    users.users.nextcloud.isSystemUser = true;
    users.groups.nextcloud = {};
  })
  ]);
}
