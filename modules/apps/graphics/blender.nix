# gaming/steam.nix
#	Make steam works on your system
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
    enable = mkOption {
      type = types.bool;
      default = gfx.enable;
      description = ''
        3D Creation/Animation/Publishing System
      '';
    };
    useHIP = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Software like Blender may support HIP for GPU acceleration.
        Most software has the HIP libraries hard-coded. You can work around it on NixOS by using: 
      '';
    };
  };
  #config
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      if cfg.useHIP then [ blender-hip ] else [ blender ];
  };
}

