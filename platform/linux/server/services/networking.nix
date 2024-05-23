# linux/server/services.nix
#   nixos native services to run on a server
{ lib, config, ... }:
let cfg = config.nixos.server.networking;
in {
  options.nixos.server.networking = with lib; {
    containerBridge = {
      enable = mkEnableOption "host bridge for nixos containers";

      name = mkOption {
        description = "bridge name to use";
        type = types.string;
        default = "br0";
      };
      interface = mkOption {
        description = "bridge interface to use";
        type = types.string;
      };
    };
  };

  config = lib.mkIf cfg.containerBridge.enable {
    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "ens3";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };

    networking.bridges."${cfg.containerBridge.name}".interfaces =
      [ cfg.containerBridge.interface ];
    networking.interfaces."${cfg.containerBridge.name}".useDHCP = true;
    # make all containers use the bridge
    containers = builtins.mapAttrs (name: value: {
      privateNetwork = lib.mkForce true;
      hostBridge = cfg.containerBridge.name;
    }) config.containers;
  };
}
