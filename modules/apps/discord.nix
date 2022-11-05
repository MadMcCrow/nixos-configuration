# apps/discord.nix
# 	discord chat app
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  cfg = config.apps.discord;
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
  options.apps.discord.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable discord : voice and text chat for gamers";

  };
  # import unfree to allow programs
  imports = [ ./unfree.nix ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ discord nss_latest ];
    nixpkgs.overlays = [ OpenASAR ];
    unfree.allowedUnfree = [ "discord" ];
  };
}
