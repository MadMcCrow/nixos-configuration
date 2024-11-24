# TODO:
# https://nixos.wiki/wiki/Blocky
{ lib, config, ... }:
let
  cfg = nixos.server.services.blocky;
in
{
  options.nixos.server.services.blocky = with lib; {
    enable = mkEnableOption "blocky DNS";
  };

  # implementation
  config = lib.mkIf cfg.enable {
    services.blocky.enable = true;
    services.blocky.settings = { };
  };
}
