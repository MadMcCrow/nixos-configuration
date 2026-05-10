# gog.nix
# gog support
# TODO : test and improve !
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.games.gog.enable = lib.mkEnableOption "GoG games support";
  config = lib.mkIf config.games.gog.enable {
    environment.systemPackages = with pkgs; [ minigalaxy ];
  };
}
