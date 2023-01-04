# input-remapper.nix
# 	a GUI tool to remap your inputs
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  ipt = config.input;
  cfg = ipt.remapper;
  pkg = pkgs.input-remapper;
in {
  #interface
  options.input.remapper.enable = mkEnableOption (mdDoc ''
    input-remapper, a tool to remap your mouse and/or keyboard
  '');
  # config
  config = mkIf (ipt.enable && cfg.enable) {
    environment.systemPackages = [ pkg ];
    services.input-remapper = {
      enable = true;
      package = pkg;
      enableUdevRules = true;
    };
  };
}

