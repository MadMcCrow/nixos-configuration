# debugtools.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # cfg shortcut
  dev = config.apps.development;
  cfg = dev.lapce;
in {
  # interface
  options.apps.development.lapce = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Add the new lapce editor
    '';
  };
  # add github tools
  config = mkIf cfg { environment.systemPackages = with pkgs; [ lapce ]; };

}
