# adguard home is a DNS / adblock service
{ config, lib, pkgs, ... }:
let cfg = config.nixos.server.services.adguard;
in {
  # interface
  options.nixos.server.services.adguard = with lib; {
    enable = mkEnableOption "adguard instance";
    dataDir = mkOption {
      description = "path to the adguardhome storage folder";
      type = types.path;
      example = "/www/adguardhome";
    };
  };

  # implementation
  config = lib.mkIf cfg.enable {

    # our actual container :
    containers."adguard" = {
      # start at boot :
      autoStart = true;
      # container networking :
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      # use host nix-store and nixpkgs config
      nixpkgs = pkgs.path;
      # do not store anything
      ephemeral = false;
      # we can't really set agh working directory so we map the whole container
      bindMounts = {
        "/" = {
          hostPath = "${cfg.dataDir}";
          isReadOnly = false;
        };
      };
      config = { ... }: {
        services.adguardhome = {
          enable = true;
          settings = {
            bind_port = 3002;
            http.address = "0.0.0.0:3002";
            dhcp.enabled = false;
          };
          openFirewall = true;
        };

        # open firewall
        # 53   -> DNS
        # 3002 -> webadmin
        # 445  -> https webadmin
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ 53 3002 445 ];
        };
        networking.domain = config.networking.domain;
        system.stateVersion = config.system.stateVersion;
      };
    };

    # open firewall to access adguard
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 53 3002 445 ];
    };

    # make sure the dataDir exists on Host
    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0755 root root -" ];

    # delay container start to bindMount creation :
    systemd.services."container@adguard" = {
      wants = [ "systemd-tmpfiles-setup.service" ];
      after = [ "systemd-tmpfiles-setup.service" ];
    };

  };
}
