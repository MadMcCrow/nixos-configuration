# apps/pidgin.nix
# 	pidgin chat app
{ pkgs, config, lib, unfree, ... }:
with builtins;
with lib;
let
  # config interface
  web = config.apps.web;
  cfg = web.pidgin;
in {
  # interface
  options.apps.web.pidgin.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable pidgin :a multi protocol chat client";
  };
  #config
  config = lib.mkIf cfg.enable {
    apps.packages = with pkgs; [
      signald
      pidgin
      # we cannot merge this list with
      # the one used in nixpkgs.config.packageOverrides
      # because it creates and infinite recursion
      pidgin-skypeweb
      pidgin-opensteamworks
      pidgin-otr
      purple-plugin-pack
      purple-slack
      purple-discord
      purple-matrix
      tdlib-purple
      purple-matrix
      purple-signald
    ];

    # set plugins
    nixpkgs.config.packageOverrides = pkgs:
      with pkgs; {
        pidgin = pkgs.pidgin.override {
          ## Add whatever plugins are desired (see nixos.org package listing).
          plugins = [
            pidgin-skypeweb
            pidgin-opensteamworks
            pidgin-otr
            purple-plugin-pack
            purple-slack
            purple-discord
            purple-matrix
            tdlib-purple
            purple-matrix
            purple-signald
          ];
        };
      };

    # purple discord might be unfree
    # unfree.unfreePackages = [ "purple-discord" ];
  };
}
