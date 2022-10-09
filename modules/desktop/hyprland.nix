# hyprland.nix
#	A neat looking DE
{ config, pkgs, lib, hyprland, ... }:
with builtins;
with lib;
let cfg = config.hyprland;

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

  imports = [ hyprland.nixosModules.default ];

  config = mkIf cfg.enable {

    programs.hyprland = {
      enable = true;
      package = hyprland.packages.${pkgs.system}.default;
    };
  };
}
