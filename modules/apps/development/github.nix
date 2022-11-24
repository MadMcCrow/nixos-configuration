# debugtools.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
let
  # cfg shortcut
  dev = config.apps.development.enable;
  cfg = config.apps.development.github;
in {
  #
  # interface
  # 
  options.apps.development.github = lib.mkOption {
    type = types.bool;
    default = dev;
    description = ''
      Add Github tools to your path
    '';
  };

  # add github tools
  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [ git gh gh-eco gh-cal gh-dash ];
  };

}
