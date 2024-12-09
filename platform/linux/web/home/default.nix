{ lib, ... }:
{
  options.nixos.web.home = with lib; {
    subDomain = lib.mkOption {
      description = "subdomain for home web app";
      default = "home";
    };
  };

  imports = [
    # ./homepage.nix 
  ];
}
