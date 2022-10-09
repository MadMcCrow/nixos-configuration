# apps/discord.nix
# 	discord chat app
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.apps.discord;
in {
  options.apps.discord.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable discord : voice and text chat for gamers";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ discord ];
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "discord" ];

    pkgs.discord.override {
    nss = pkgs.nss_3_83;
    }
  };
}
