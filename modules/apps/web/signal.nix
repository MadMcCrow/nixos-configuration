# apps/signal.nix
# 	signal secure messaging desktop app
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  #config interface
  web = config.apps.web;
  cfg = web.signal;
in {
  #interface
  options.apps.web.signal.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable signal, the messaging app ";
  };
  # config
  config = lib.mkIf cfg.enable {
    apps.packages = with pkgs; [ signald signal-desktop ];
  };
}
