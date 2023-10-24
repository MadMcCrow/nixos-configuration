# linux/server/nextcloud/default.nix
#   all that is necessary for getting nextcloud to work OOTB
#   TODO:
#         - use container !
#         - move secret to sub-module
#         - Enable HTTPS
#         - Remote access (ie from outside of my local network)
{ pkgs, config, lib, ... }:
with builtins;
let
  # shortcuts
  srv = config.nixos.server;
  cfg = srv.nextcloud;

  # helper function
  condArg = n: s: d: if hasAttr n s then getAttr n s else d;
  mkStringOption = description: default:
    lib.mkOption {
      inherit default description;
      type = lib.types.str;
    };

  mkPath = l: lib.concatStringsSep "/" l;

  # path to our data
  nextcloudPath = mkPath [ config.nixos.server.data.path "nextcloud" ];

  # pass to decrypted nextcloud password
  nextcloudSecret = cfg.passwordPath;

  # can nextcloud work :
  # we cannot at instantiation time check
  # if the password will be working at
  # runtime. the best we could do would be
  # IFD. we don't want IFD.
  nextcloudEnable = true; # pathExists nextcloudSecret;

in {
  # interface:
  options.nixos.server.nextcloud = {
    enable = lib.mkEnableOption "nextcloud" // {
      default = config.nixos.server.enable;
    };
    hostName = mkStringOption "hostname for nextcloud instance"
      "nextcloud.${srv.hostName}";
    passwordPath =
      mkStringOption "path for password file" "/etc/nextcloud/secret/pass";
  };

  # sub-modules
  imports = [ ./sql.nix ./apps.nix ];

  # config
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # our secrets for password
      # this gets generated with nixos-update-secrets
      secrets.secrets = [{
        name = "nextcloud";
        path = nextcloudSecret;
      }];

      # force updating secrets before initialisations :
      # systemd.services."nextcloud-setup" = {
      #    requires = [ "${config.secrets.update.pname}.service" ];
      #    after = [ "${config.secrets.update.pname}.service" ];
      # };
    }

    # if nextcloud can be enabled then do it:
    (lib.optionalAttrs nextcloudEnable {

      # nextcloud user
      # users.users.nextcloud.uid = lib.mkForce 115;
      # users.groups.nextcloud.gid = lib.mkForce 121;
      users.users.nextcloud.group = "nextcloud";
      users.users.nextcloud.extraGroups = [ "ssl-cert" ];

      # ensure data folder
      systemd.tmpfiles.rules = [
        "d ${nextcloudPath}         0750 nextcloud nextcloud -"
        "d ${dirOf nextcloudSecret} 0750 nextcloud nextcloud -"
      ];

      # start nextcloud after secret is ready :
      systemd.services."nextcloud-setup" = {
        requires = [ config.secrets.service.name ];
        after = [ config.secrets.service.name ];
      };

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
      users.groups.nextcloud = { };
    })
  ]);
}
