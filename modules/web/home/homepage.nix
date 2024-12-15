# Homepage is a nice dashboard to see everything
# https://github.com/gethomepage/homepage/
{ config, lib, ... }:
let
  inherit (config.nixos) web;
  port = 8082;
in
{
  # interface
  options.nixos.web.home.homepage = with lib; {
    enable = mkEnableOption "" // {
      default = web.enable;
    };
  };
  # 
  config = lib.mkIf web.home.homepage.enable {
    nixos.web.services."homepage" = {
      services.homepage-dashboard = {
        enable = true;
        listenPort = port;
        openFirewall = true;
      };
    };
  };
}
