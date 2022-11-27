# debugtools.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # cfg shortcut
  dev = config.apps.development.enable;
  cfg = dev.debugtools;
in {
  # interface
  options.apps.development.debugtools.enable = mkOption {
    type = types.bool;
    default = dev;
    description = ''
      Debug tools are GUI tools to help with debugging and performance measures
    '';
  };
  # add debug programs
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ nemiver sysprof ];
  };

}
