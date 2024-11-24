# Homepage is a nice dashboard to see everything
# https://github.com/gethomepage/homepage/
{ config, lib, ...} : 
let
   web = config.nixos.web;
   port = 8082;
in
{
  # interface
  options.nixos.web.homepage = with lib; {
    subDomain = mkOption {
      description = "subdomain for the web service acting as home folder";
      default = "home";
    };
  };
  # 
  config = lib.mkIf web.enable {
    nixos.web.containers."homepage" = {
     services.homepage-dashboard = {
        enable = true;
        listenPort = 8082;
        openFirewall = true;
     };
    };
  };
}