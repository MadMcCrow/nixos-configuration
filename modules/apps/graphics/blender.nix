# graphics/blender.nix
#	add the blender 3d modeling software to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # config interface
  gfx = config.apps.graphics;
  cfg = gfx.blender;
in {
  # interface
  options.apps.graphics.blender = {
    # dis
    enable = mkEnableOption (mdDoc "3D Creation/Animation/Publishing System");
    useHIP = mkEnableOption (mdDoc
      "HIP. Software like Blender may support HIP for GPU acceleration.");
  };
  #config
  config = mkIf cfg.enable {
    apps.packages = with pkgs;
      if cfg.useHIP then [ blender-hip ] else [ blender ];
  };
}

