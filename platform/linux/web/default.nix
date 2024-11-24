# server/default.nix
# 	each server service is enabled in a separate sub-module
{ ... }:
{

  # interface
  options.nixos.server = with lib; {
    enable = mkEnableOption "server services and packages";
    # Domain Name for the services
    domainName = mkOption {
      description = "a domain name for all the hosted services";
      type = with types; nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+.[a-z]+)" s) != null));
      example = "cool-domain.com";
      default = config.networking.domain;
    };
    # email
    adminEmail = mkOption {
      description = "email to contact in case of problem";
      type = with types; nullOr (addCheck str (s: (builtins.match "([a-z0-9+.]+@[a-z0-9.]+)" s) != null));
      example = "admin@server.net";
    };
  };

  # definitions are in another module
  imports = [
    ./auth
    ./dashboard
    ./dns
    ./nextcloud
    ./video
  ];

}
