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

  # sadly there's no better way
  nextcloudPkg = pkgs.nextcloud27;

in {
  # interface
  options.nixos.server = {
    enable = mkEnableOptionDefault "server services" false;
    nextcloud.enable = mkEnableOptionDefault "nextcloud" true;
    cockpit.enable = mkEnableOptionDefault "cockpit web-based interface" true;
    seafile.enable = mkEnableOptionDefault "seafile file manager" true;
  };

  config = mkIf cfg.enable {

    # nextcloud 
    services.nextcloud = mkIf cfg.nextcloud.enable {
      enable = true;
      package = nextcloudPkg;
      hostName = "localhost";
      config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
    };

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
  };
}
