# apps/firefox.nix
# 	firefox web browser
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  #config interface
  web = config.apps.web;
  cfg = web.firefox;
  # compat with wayland
  firefox-compat = if config.programs.xwayland.enable then
    pkgs.firefox-wayland
  else
    pkgs.firefox;
in {
  #interface
  options.apps.web.firefox = {
    enable = mkEnableOption (mdDoc "firefox browser") // {
      default = web.enable;
    };
    wayland = mkEnableOption (mdDoc "the wayland compatible version") // {
      default = config.programs.xwayland.enable;
    };
    pocket = mkEnableOption (mdDoc "pocket : a tool to manage your favorites");
    prediction = mkEnableOption (mdDoc "network prediction for faster searches")
      // {
        default = true;
      };
  };
  #config
  config = lib.mkIf cfg.enable {
    apps.packages = [ firefox-compat ];
    # 22.11 channel !
    programs.firefox = {
      enable = true;
      package = firefox-compat;
      policies = {
        DisablePocket = !cfg.pocket;
        NetworkPrediction = cfg.prediction;
      };
    };
    unfree.unfreePackages = [ "widevine-cdm" ];
  };
}
