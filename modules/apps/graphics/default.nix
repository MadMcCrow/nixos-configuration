# apps/graphics/default.nix
# 	all the apps we want on our systems
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  # config interface
  cfg = config.apps.graphics;
in {
  #interface
  options.apps.graphics.enable = mkEnableOption (mdDoc "a suite of programs to edit 2d and 3d files");
  #imports
  imports = [ ./blender.nix ./gimp.nix ./inkscape.nix ];
}
