# apps/games/default.nix
# 	all the apps we want on our systems
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  # config interface
  cfg = config.apps.graphics;
in {
  #interface
  options.apps.graphics = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable a suite of programs to edit 2d and 3d files.
      '';
    };
  };
  #imports
  imports = [ ./blender.nix ./gimp.nix ./inkscape.nix ];
}
