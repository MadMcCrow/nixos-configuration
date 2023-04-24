# apps/games/default.nix
# 	all the apps we want on our systems
{ pkgs, config, nixpkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  # config interface
  cfg = config.apps.games;
in {
  options.apps.games = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable a list of gaming related programs
      '';
    };
  };
  imports = [ ./steam.nix ./gamemode.nix ];
}
