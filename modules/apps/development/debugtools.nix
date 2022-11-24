# debugtools.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
let
  # cfg shortcut
  dev = config.apps.development.enable;
  cfg = config.apps.development.debugtools;
in {
  #
  # interface
  # 
  options.apps.development.debugtools = lib.mkOption {
    type = types.bool;
    default = dev;
    description = ''
      Debug tools are GUI tools to help with debugging and performance measures
    '';
  };

  # add debug programs
  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [ nemiver sysprof ];
  };

}
