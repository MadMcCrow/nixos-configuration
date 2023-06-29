# nextcloud.nix
# 	Nixos nextcloud installation
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let srv = config.server;
let cfg = srv.nextcloud;
in {

  # interface
  options.server.nextcloud = {
    # do you want a nexcloud instance
    enable = lib.mkEnableOption "Nextcloud service" // {default = true;};
  };

  # base config for nextcloud 
  config = lib.mkIf (srv.enable && cfg.enable) {

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud25;
      hostName = "localhost";
      config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
    };
  };
}
