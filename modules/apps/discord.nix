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
    environment.systemPackages = with pkgs; [ discord nss_latest ];
    nixpkgs = {
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [ "discord" ];

    # https://nixos.wiki/wiki/discord#Opening_Links_with_Firefox
    # discord.override = with pkgs; { nss = nss_latest; };
    };
  };
}
