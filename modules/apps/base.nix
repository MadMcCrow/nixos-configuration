# apps/base.nix
# 	the apps we "always" want on our system
{ config, pkgs, ... }:
let
  cfg = config.apps.base;
  firefox-compat =
    if config.programs.xwayland.enable then firefox-wayland else firefox;
in {

  # interface
  options.apps.base.enable = lib.mkOption {
    type = types.bool;
    default = true;
    description = "add some basic apps to your installation";
  };

  # config
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wget
      curl
      zip
      neofetch
      firefox-compatible
    ];
  };
}

