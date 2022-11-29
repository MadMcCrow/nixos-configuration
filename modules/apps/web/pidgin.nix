# apps/pidgin.nix
# 	pidgin chat app
{ pkgs, config, lib, unfree, ... }:
with builtins;
with lib;
let
  # config interface
  web = config.apps.web;
  cfg = web.pidgin;

  pidginPlugins = with pkgs; [
    pidgin-skypeweb
    pidgin-opensteamworks
    pidgin-otr
    purple-slack
    purple-discord
    purple-matrix
    purple-matrix
    purple-signald
  ];

  # pidgin-with-plugins
  pidgin-with-plugins = pkgs.pidgin.override { plugins = pidginPlugins; };

in {
  # interface
  options.apps.web.pidgin.enable = lib.mkOption {
    type = types.bool;
    default = web.enable;
    description = "enable pidgin :a multi protocol chat client";
  };
  #config
  config = lib.mkIf cfg.enable {
    apps.packages = with pkgs; [ signald pidgin ] ++ pidginPlugins;

    # not working (yet)
    # set plugins
    #apps.overrides = {
    #  pkgs.pidgin = pidgin-with-plugins; 
    #};
    #nixpkgs.config.packageOverrides = pkgs: { pkgs.pidgin = pidgin-with-plugins; };

    # purple discord might be unfree
    unfree.unfreePackages = [ "purple-slack" "purple-discord" "pidgin-otr" ];
  };
}
