# networking options for web server
{lib, config, ...} :
let
  cfg = config.nixos.web.networking;
in
{
  # interface :
  options.nixos.web.networking = with lib; {
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

  # 
  config = lib.mkIf cfg.enable {
    # let's have ping
    environment.systemPackages = [ pkgs.inetutils ];
    # 
    networking = lib.mkIf cfg.containerBridge.enable {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = "ens3";
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };
      bridges."${cfg.containerBridge.name}".interfaces = [ cfg.containerBridge.interface ];
      interfaces."${cfg.containerBridge.name}".useDHCP = true;
    };

    # make all containers use the bridge
    # containers = builtins.mapAttrs (name: value:
    #   value // (lib.mkIf cfg.containerBridge.enable {
    #     privateNetwork = lib.mkForce true;
    #     hostBridge = cfg.containerBridge.name;
    #   })) config.containers;

    # enable extra layer of security on servers
    security.apparmor.enable = true;
  };
}