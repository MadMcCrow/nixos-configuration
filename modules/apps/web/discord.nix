# apps/discord.nix
# 	discord chat app
{ pkgs, config, lib, unfree, ... }:
with builtins;
with lib;
let
  web = config.apps.web;
  cfg = web.discord;
  # use OpenASAR for faster start-up times
  OpenASAR = self: super: {
    discord = super.discord.override { withOpenASAR = true; };
  };
  # Make sure to always download the latest tarball
  # this cannnot work in pure evaluation because 
  # you would need to know the sha256 in advance 
  # when updating discord
  # ForceUpdate = self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball <link-to-tarball>;});};
in {
  # interface
  options.apps.web.discord.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable discord : voice and text chat for gamers";
  };
  #config
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ discord nss_latest ];
    nixpkgs.overlays = [ OpenASAR ];
    unfree.unfreePackages = [ "discord" ];
  };
}
