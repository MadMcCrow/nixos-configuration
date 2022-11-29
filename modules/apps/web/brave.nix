# apps/brave.nix
# 	brave browser
#       todo : build nightly
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  web = config.apps.web;
  cfg = web.brave;
in {
  options.apps.web.brave.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable the brave browser if true";
  };
  config = lib.mkIf cfg.enable {
    apps.packages = with pkgs; [ brave widevine-cdm ];
    nixpkgs.config.chromium = { enableWideVine = true; };
  };
}
