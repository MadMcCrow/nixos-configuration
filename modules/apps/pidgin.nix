# apps/pidgin.nix
# 	pidgin chat app
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.apps.pidgin;
in {
  options.apps.pidgin.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable pidgin :a multi protocol chat client";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        signald
        #pidgin
      ];

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

    # may be necessary
    # nixpkgs.config.allowUnfreePredicate = pkg:
    #  builtins.elem (lib.getName pkg) [ ];
  };
}
