# hyprland.nix
#	A neat looking DE
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.hyprland;

in {

  # interface
  options.hyprland = {
    # do you want hyprland Desktop environment
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = "enable hyprland Desktop environment";
    };
    };

  config = mkIf cfg.enable;  {
  modules = [ hyprland.nixosModules.default { programs.hyprland.enable = true} ];
  };
}
