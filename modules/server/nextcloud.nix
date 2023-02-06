# nextcloud.nix
# 	Nixos nextcloud installation
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.server.nextcloud;
in {

  # interface
  options.server.nextcloud = {
    # do you want a nexcloud instance
    enable = lib.mkEnableOption "Nextcloud service";
  };

  # base config for gnome 
  config = lib.mkIf cfg.enable {
  
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud25;
      hostName = "localhost";
      config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
    };
  };
}
