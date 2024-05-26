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
    environment.defaultPackages = with pkgs; [
      ifwifi
      networkmanager
      dnsutils
      nmap
    ];

    #
    networking = {
      # unique identifier for machines
      hostId = (elemAt
        (elemAt (split "(.{8})" (hashString "md5" config.networking.hostName))
          1) 0);

      # use dhcp for addresses. static adresses are given by the rooter
      useDHCP = lib.mkForce true;
      enableIPv6 = true;

      dhcpcd.persistent = true;

      #
      networkmanager.enable = true;

      # enable firewall with quite open ports
      firewall = {
        allowedTCPPorts = [ 27036 27015 22 ];
        allowedUDPPortRanges = [{
          from = 27031;
          to = 27036;
        } # Steam remote play support
          ];
        allowedUDPPorts = [ 27015 ]; # Gameplay traffic
      };

      # WOL needs hard definition of interfaces
      interfaces = listToAttrs (map (x: {
        name = "${x}";
        value = { wakeOnLan.enable = true; };
      }) cfg.wakeOnLineInterfaces);
    };

    # avahi for mdns :
    services.avahi = rec {
      enable = true;
      nssmdns = true;
      ipv6 = true;
      ipv4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        domain = true;
        workstation = true;
        userServices = true;
        addresses = true;
        hinfo = true;
      };
      # may prevent to detect samba shares
      domainName = lib.mkIf (config.networking.domain != null) config.networking.domain; # defaults to "local";
      browseDomains = [
       domainName
      ] ++ ( lib.lists.optional (config.nixos.server.domainName != null) config.nixos.server.domainName);
    };
  };
}
