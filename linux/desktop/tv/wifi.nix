# wifi.nix
# helper to get wifi going on TV box
{ config, pkgs, lib, ... }:
lib.mkIf config.nixos.tv.enable {
  # for now add nmtui to do the config easily
  environment.systemPackages = with pkgs; [ nmtui ];
}
