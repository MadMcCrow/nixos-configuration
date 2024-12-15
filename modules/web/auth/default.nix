# use authelia in nixos
{ lib, ... }:
{
  # interface
  options.nixos.web.auth = with lib; {
    subDomain = mkOption {
      description = "subdomain for authentification service";
      type =
        with types;
        nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+)" s) != null));
      default = "auth";
    };
  };

  # implementation
  imports = [ ./authelia.nix ];
}
