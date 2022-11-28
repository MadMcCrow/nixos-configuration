# debugtools.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # config interface
  aps = config.apps;
  dev = aps.development;
  cfg = dev.lapce;
in {
  # interface
  options.apps.development.lapce = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Add the new lapce editor
      '';
    };
  };
  # add github tools
  config = mkIf cfg.enable { apps.packages = with pkgs; [ lapce ]; };

}
