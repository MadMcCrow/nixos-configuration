# apps/brave.nix
# 	brave browser
#       todo : build nightly
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  web = config.apps.web;
  cfg = web.firefox;
  # compat with wayland
  firefox-compat = if config.programs.xwayland.enable then
    pkgs.firefox-wayland
  else
    pkgs.firefox;
in {
  options.apps.web.firefox = {
    enable = lib.mkOption {
      type = types.bool;
      default = web.enable;
      description = "enable the firefox browser if true";
    };
    wayland = lib.mkOption {
      type = types.bool;
      default = config.programs.xwayland.enable;
      description = "if true, use the wayland compatible version";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ firefox-compat ];
    # 22.11 channel !
    programs.firefox = {
      enable = true;
      package = firefox-compat;
      policies = {
        DisablePocket = true;
        NetworkPrediction = true;
        SanitizeOnShutdown = true;
      };
    };
    unfree.unfreePackages = [ "widevine-cdm" ];
  };
}
