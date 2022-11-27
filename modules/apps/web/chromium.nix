# apps/chromium.nix
# 	chromium browser
{ pkgs, config, lib, unfree, ... }:
with builtins;
with lib;
let
  web = config.apps.web;
  cfg = web.chromium;
in {
  #interface
  options.apps.web.chromium.enable = mkOption {
    type = types.bool;
    default = false;
    description = "enable the chromium browser if true";
  };
  #config
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ chromium widevine-cdm ];
    # make sure chromium has widevine (L1 - SD support only)
    nixpkgs.config.chromium = { enableWideVine = true; };
    unfree.unfreePackages = [ "chromium" ];
  };
}
