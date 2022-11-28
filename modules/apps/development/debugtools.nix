# debugtools.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # config interface
  dev = config.apps.development;
  cfg = dev.debugtools;
in {
  # interface
  options.apps.development.debugtools = {
    enable = mkOption {
      type = types.bool;
      default = dev.enable;
      description = ''
        Debug tools are GUI tools to help with debugging and performance measures
      '';
    };
    list = mkOption {
      type = types.listOf types.package;
      default = dev.enable;
      description = ''
        Debug tools are GUI tools to help with debugging and performance measures
      '';
    };
  };
  # add debug programs
  config = mkIf cfg.enable { apps.packages = with pkgs; [ nemiver sysprof ]; };

}
