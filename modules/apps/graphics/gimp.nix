# graphics/gimp.nix
# 	Setup gimp and add plugins 
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # config interface
  gfx = config.apps.graphics;
  cfg = gfx.gimp;
  # inkscape extensions
  extensions = with pkgs.gimpPlugins; [ gap bimp fourier texturize ];

in {
  options.apps.graphics.gimp = {
    enable = mkOption {
      type = types.bool;
      default = gfx.enable;
      description = ''
        add the photo editing tool gimp
      '';
    };
  };

  config = mkIf cfg.enable {
    apps.packages = with pkgs;
      [ (gimp-with-plugins.override { plugins = extensions; }) ];
  };
}
