# github.nix
# 	Add github cli tools to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # config interface
  dev = config.apps.development;
  cfg = dev.github;
in {
  # interface
  options.apps.development.github = {
    enable = mkOption {
      type = types.bool;
      default = dev.enable;
      description = ''
        Add Github tools to your path
      '';
    };
  };
  #config
  config = mkIf cfg.enable {
    apps.packages = with pkgs; [ git gh gh-eco gh-cal gh-dash ];
    programs.git = {
      enable = true;
      config = {
        help.autocorrect = 10;
        color.ui = "auto";
      };
      lfs = { enable = true; };
    };
  };

}
