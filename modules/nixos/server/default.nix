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

in {
  # interface
  options.nixos.server = {
    enable = mkEnableOptionDefault "server services" false;
    cockpit.enable = mkEnableOptionDefault "cockpit web-based interface" true;
    seafile.enable = mkEnableOptionDefault "seafile file manager" true;
  };

  imports = [./nextcloud.nix];

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
  };
}
