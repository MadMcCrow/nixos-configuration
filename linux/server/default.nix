# server/default.nix
# 	each server service is enabled in a separate sub-module
#   TODO : use containers !
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

  # basically nextcloud.hostname;
  nextcloudHostName = "nextcloud.${cfg.hostName}";
in {

  # interface
  options.nixos.server = {
    enable = mkEnableOptionDefault "server services" false;
    adminEmail =
      mkStringOption "email to contact in case of problem" "admin@server.net";
    hostName = mkStringOption "server host name" "localhost";
    cockpit.enable = mkEnableOptionDefault "cockpit web-based interface" false;
    seafile.enable = mkEnableOptionDefault "seafile file manager" false;
    data.path =
      mkStringOption "path to store data for the server" "/persist/server/data";
  };

  # nextcloud is in another module :
  imports = [ ./nextcloud ./dns ];

  # server configuration
  config = mkIf cfg.enable {

    # SSL :
    users.groups.ssl-cert.gid = 119;

    # cockpit (web-based server interface )
    services.cockpit = mkIf cfg.cockpit.enable {
      enable = true;
      openFirewall = true;
      port = 9090;
    };

    # seafile
    services.seafile = mkIf cfg.seafile.enable {
      inherit adminEmail;
      enable = true;
    };

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

  };
}
