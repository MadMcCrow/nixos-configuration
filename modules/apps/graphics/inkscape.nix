# graphics/inkscape.nix
# 	Setup inkscape and all it's things 
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # config interface
  gfx = config.apps.graphics;
  cfg = gfx.inkscape;
  # inkscape extensions
  extensions = with pkgs.inkscape-extensions; [ inkcut applytransforms ];
in {
  options.apps.graphics.inkscape = {
    enable = mkOption {
      type = types.bool;
      default = gfx.enable;
      description = ''
        add the vector graphics tool inkscape.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        (inkscape-with-extensions.override { inkscapeExtensions = extensions; })
      ];
  };
}
