# debugtools.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
let
  # cfg shortcut
  cfg = config.apps.development.lapce;
in {
  #
  # interface
  # 
  options.apps.development.lapce = lib.mkOption {
    type = types.bool;
    default = false;
    description = ''
      Add the new lapce editor
    '';
  };

  # add github tools
  config = lib.mkIf cfg { environment.systemPackages = with pkgs; [ lapce ]; };

}
