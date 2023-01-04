# ratbag.nix
# 	a tool to configure your gaming mouse
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  ipt = config.input;
  cfg = ipt.ratbag;
in {
  # interface
  options.input.ratbag.enable =
    mkEnableOption (mdDoc "ratbag, a tool to customise your gaming mouse");
  # config
  config = mkIf (ipt.enable && cfg.enable) {
    services.ratbagd.enable = true;
    environment.systemPackages = with pkgs; [ libratbag piper ];
  };
}
