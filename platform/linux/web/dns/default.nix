{ lib, config, ... }:
{
  options.nixos.web.dns = with lib; {
    enable = mkEnableOption "DNS service" // {
      default = config.nixos.web.enable;
    };
    port = mkOption {
      type = types.int;
      description = "port for DNS service";
      default = 53;
    };
    # using multi dns is a bad idea
    subDomain = mkOption {
      description = "subdomain to use for DNS service";
      type = with types; nullOr (addCheck str (s: (builtins.match "([a-z0-9-]+)" s) != null));
      default = "dns";
    };

    implementation = mkOption {
      description = "which DNS are we using";
      type = types.enum [
        "adguard"
        "blocky"
      ];
      default = "adguard";
    };

    upstreams = mkOption {
      description = "";
      type = with types; listOf str;
      default = [
        # Open DNS (Cisco)
        "208.67.222.222"
        "208.67.220.220"
        "208.67.222.220"
        "2620:119:35::35"
        "2620:119:53::53"
        # Level3
        "4.2.2.1"
        "4.2.2.2"
      ];
    };

  };
  # choose only one !
  imports = [
    ./adguard.nix
    #  ./blocky.nix
  ];
}
