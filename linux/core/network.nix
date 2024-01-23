# linux/network.nix
#	networking setup for my linux machines
{ pkgs, config, lib, ... }:
with builtins;
let
  # shortcut
  cfg = config.nixos.network;

in {
  # interface
  options.nixos.network = with lib.types; {
    # useDHCP = mkEnableOptionDefault "use DHCP" true; # useless, just use dhcp with rooter configuration
    wakeOnLineInterfaces = lib.mkOption {
      type = (listOf str);
      description = "Interfaces to enable wakeOnLan";
      default = [ ];
    };
  };

  # implementation
  config = {

    # add necessary tools :
    environment.defaultPackages = with pkgs; [ ifwifi networkmanager ];

    networking = {
      # unique identifier for machines
      hostId = (elemAt
        (elemAt (split "(.{8})" (hashString "md5" config.networking.hostName))
          1) 0);

      # use dhcp for addresses. static adresses are given by the rooter
      useDHCP = lib.mkDefault true;
      enableIPv6 = true;

      networkmanager.enable = true;

      firewall = {
        allowedTCPPorts = [ 27036 27015 22 ];
        allowedUDPPortRanges = [{
          from = 27031;
          to = 27036;
        } # Steam remote play support
          ];
        allowedUDPPorts = [ 27015 ]; # Gameplay traffic
      };

      interfaces = listToAttrs (map (x: {
        name = "${x}";
        value = { wakeOnLan.enable = true; };
      }) cfg.wakeOnLineInterfaces);
    };

    # avahi for mdns :
    services.avahi = {
      enable = true;
      nssmdns4 = true; # ipv4
      nssmdns6 = true; # ipv6
    };
  };
}
