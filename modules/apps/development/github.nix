# debugtools.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # cfg shortcut
  dev = config.apps.development.enable;
  cfg = dev.github;
in {
  #
  # interface
  # 
  options.apps.development.github = mkOption {
    type = types.bool;
    default = dev;
    description = ''
      Add Github tools to your path
    '';
  };

  # add github tools
  config = mkIf cfg {
    environment.systemPackages = with pkgs; [ git gh gh-eco gh-cal gh-dash ];
  };

}
