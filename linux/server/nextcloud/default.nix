# linux/server/nextcloud/default.nix
#   all that is necessary for getting nextcloud to work OOTB
#   TODO:
#         - use container !
#         - Enable HTTPS
#         - Remote access (ie from outside of my local network)
{ pkgs, config, lib, ... }:
let
  # shortcuts
  srv = config.nixos.server;
  cfg = srv.nextcloud;
  mkPath = l: lib.concatStringsSep "/" l;

  nextcloudHostName = "nextcloud.${srv.hostName}";
  nextcloudPath = cfg.dataPath;

in {
  # interface:
  options.nixos.server.nextcloud = {
    enable = lib.mkEnableOption "nextcloud" // { default = srv.enable; };

    dataPath = lib.mkOption {
      type = lib.types.path;
      description = "path to encrypted file";
      example = "nix/persist/server/nextcloud";
    };
  };

  # sub-modules
  imports = [ ./sql.nix ./apps.nix ];

  # config
  config = lib.mkIf cfg.enable {

    # our secrets for password
    # this gets generated with nixos-update-secrets
    secrets.secrets."nextcloud-pass" = {
      keys = [ "${nextcloudPath}/ssh/rsa" ];
      service = "nextcloud-setup.service";
      encrypted = "${nextcloudPath}/pass/password.age";
      decrypted = "${nextcloudPath}/pass/password";
      user = "nextcloud";
    };

    # nextcloud user
    # users.users.nextcloud.uid = lib.mkForce 115;
    # users.groups.nextcloud.gid = lib.mkForce 121;
    users.users.nextcloud.group = "nextcloud";
    users.users.nextcloud.extraGroups = [ "ssl-cert" ];

    # ensure data folder
    systemd.tmpfiles.rules =
      [ "d ${nextcloudPath} 0750 nextcloud nextcloud -" ];

    # setup SSL and ACME for https :
    # services.nginx.virtualHosts.${cfg.hostName} = {
    #   forceSSL = true;
    #   enableACME = true;
    # };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      hostName = nextcloudHostName;
      datadir = nextcloudPath;
      config = {
        adminuser = "admin";
        adminpassFile = "${nextcloudPath}/pass/password";
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
  };
}
