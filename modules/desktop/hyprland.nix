# hyprland.nix
#	A neat looking DE
{ config, pkgs, lib, hyprland, ... }:
with builtins;
with lib;
let
  dsk = config.desktop;
  cfg = dsk.hyprland;
in {
  # interface
  options.desktop.hyprland = {
    # do you want hyprland Desktop environment
    enable = mkEnableOption (mdDoc "hyperland, a tiling desktop environment");
  };
  # imports
  imports = [ hyprland.nixosModules.default ];
  # config
  config = mkIf (dsk.enable && cfg.enable) {
    programs.hyprland = {
      enable = true;
      package = hyprland.packages.${pkgs.system}.default;
    };
  };
}
