# apps/discord.nix
# 	discord chat app
{ pkgs, config, lib, unfree, ... }:
with builtins;
with lib;
let
  cfg = config.apps.discord;
  # use OpenASAR for faster start-up times
  OpenASAR = self: super: {
    discord = super.discord.override { withOpenASAR = true; };
  };
  # this cannnot work in pure evaluation because 
  # you would need to know the sha256 in advance 
  # when updating discord
  # ForceUpdate = self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball <link-to-tarball>;});};
in {
  # interface
  options.apps.discord.enable =
    mkEnableOption (mdDoc "discord : voice and text chat for gamers") // {
      default = true;
    };
  #config
  config = lib.mkIf cfg.enable {
    apps.packages = with pkgs; [ discord nss_latest ];
    # TODO : switch to using nixoverlays to allow for multiple overlays 
    nixpkgs.overlays = [ OpenASAR ];
    unfree.unfreePackages = [ "discord" ];
  };
}
