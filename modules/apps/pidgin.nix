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
    environment.systemPackages = with pkgs; [
      pidgin
      pidgin-skypeweb
      pidgin-opensteamworks
      signald
    ];

    services.bitlbee.libpurple_plugins = with pkgs; [
      purple-slack
      purple-discord
      purple-matrix
      telegram-purple
      purple-matrix
      libpurple-signald
    ];

    # may be necessary
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ ];
  };
}
