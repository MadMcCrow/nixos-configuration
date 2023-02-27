# apps/signal.nix
# 	signal secure messaging desktop app
#   TODO : add server mode
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  #config interface
  web = config.apps.web;
  cfg = web.signal;
in {
  #interface
  options.apps.web.signal = {
    enable = mkEnableOption (mdDoc "signal, the messaging app");
  };
  # config
  config = lib.mkIf cfg.enable {
    apps.packages = with pkgs; [ signald signal-desktop ];
  };
}
