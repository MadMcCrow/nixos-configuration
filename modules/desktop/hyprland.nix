# hyprland.nix
#	A neat looking DE
{ config, pkgs, lib, ... }: {
  imports =
    [ hyprland.nixosModules.default { programs.hyprland.enable = true; } ];
}
