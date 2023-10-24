# linux/network.nix
#	networking setup for my linux machines
{ pkgs, config, lib, ... }:
with builtins;
let
  # shortcut
  nxs = config.nixos;
  cfg = nxs.network;

  mkOptionBase = type: description: default: lib.mkOption {inherit type description default;};

in {
  # interface
  options.nixos.network = with lib.types; {
    # systemd-networkd-wait-online can timeout and fail if there are no network interfaces available for it to manage.
    waitForOnline = mkOptionBase bool "wait for networking at boot" false;
    # useDHCP = mkEnableOptionDefault "use DHCP" true; # useless, just use dhcp with rooter configuration
    wakeOnLineInterfaces = mkOptionBase (listOf str) "Interfaces to enable wakeOnLan" [ ];
  };

  # implementation
  config = lib.mkIf nxs.enable {
    networking = {
      # use dhcp for addresses. static adresses are given by the rooter
      useDHCP = lib.mkDefault true;
      enableIPv6 = true;

      networkmanager.enable = true;
      firewall.allowedTCPPorts = [ 22 ];

      interfaces = listToAttrs (map (x: {
        name = "${x}";
        value = { wakeOnLan.enable = true; };
      }) cfg.wakeOnLineInterfaces);
    };
  };
}

