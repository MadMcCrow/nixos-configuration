# fonts.nix
# 	cool fonts I need on my systems
{ config, pkgs, lib, ... }:
let
dsk = config.nixos.desktop;
in
{
  config = lib.mkIf dsk.enable {
    environment.systemPackages = with pkgs; [
      powerline-fonts
      noto-fonts
      roboto
      open-sans
      ubuntu_font_family
      jetbrains-mono
      ];
  };
}