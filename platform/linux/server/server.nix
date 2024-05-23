{ config, lib, pkgs, ... }: {
  # interface
  options.nixos.server = with lib; {
    # email
    adminEmail = mkOption {
      description = "email to contact in case of problem";
      example = "admin@server.net";
      type = with types;
        nullOr (addCheck str
          (s: (builtins.match "([a-z0-9\+.]+@[a-z0-9.]+)" s) != null));
    };
  };

  config = {
    # let's have ping
    environment.systemPackages = [ pkgs.inetutils ];
    # let's encrypt certificate
    security.acme = {
      acceptTerms = true;
      defaults.email = config.nixos.server.adminEmail;
    };
  };
}
