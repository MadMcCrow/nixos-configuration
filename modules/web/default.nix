# server/default.nix
# 	each server service is enabled in a separate sub-module
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # shortcuts
  inherit (config) web;
in
{
  # interface
  options.web =
    with lib;
    let
      mkStrMatchOption =
        { regex, ... }@args:
        mkOption (
          (builtins.removeAttrs args [ "regex" ])
          // {
            type =
              with types;
              addCheck nonEmptyStr (s: (builtins.match regex s) != null);
          }
        );
    in
    {
      enable = mkEnableOption "server services and packages";
      dataDir = mkStrMatchOption {
        description = "path to the web server data";
        regex = "([a-z0-9+.//]+)";
      };
      # Domain Name for the services
      domain = mkStrMatchOption {
        description = "a domain name for all the hosted services";
        regex = "([a-z0-9-]+.[a-z]+)";
        example = "cool-domain.com";
        default = config.networking.domain;
      };
      # email
      adminEmail = mkStrMatchOption {
        description = "email to contact in case of problem";
        regex = "([a-z0-9+.]+@[a-z0-9.]+)";
        example = "admin@server.net";
      };
      container = {
        name = mkStrMatchOption {
          description = "internal name for the nixos container hosting the services";
          regex = "([a-z0-9]+)";
          default = "web";
        };
        useNat = mkEnableOption "NAT and bridge interface for web container";
        interface = mkStrMatchOption {
          description = "host interface for the nixos container hosting the services";
          regex = "([a-z0-9]+)";
          example = "eth0";
        };
        bridge = mkStrMatchOption {
          description = "host interface for the nixos container hosting the services";
          regex = "([a-z0-9]+)";
          default = "br0";
        };
        # TODO : allow to use a certain nixpkgs ;)
        # nixpkgs 
      };
    };

  # implementation
  config = lib.mkIf web.enable {
    # systemd-nspawn container
    containers."${web.container.name}" = {
      # do not start immediately
      autoStart = false;

      # NETWORKING :
      privateNetwork = true;
      hostAddress = "192.168.100.2";
      localAddress = "192.168.100.11";
      forwardPorts = [
        {
          containerPort = 22;
          hostPort = 2222;
          protocol = "tcp";
        }
        {
          containerPort = 80;
          hostPort = 8080;
          protocol = "tcp";
        }
      ];
      nixpkgs = pkgs.path;
      ephemeral = true;
      tmpfs = [
        "/"
        "/var"
        # add all that is necessary
      ];
      config = _: {
        imports = [ ];
        config = {

          security = {
            acme = {
              acceptTerms = true;
              email = web.adminEmail;
            };

            # apache web server : FOR NOW !
            services.httpd = {
              enable = true;
              adminAddr = web.adminEmail;
            };

            networking.firewall.allowedTCPPorts = [ 80 ];

            system = {
              switch.enable = false;
              inherit (config) stateVersion;
            };
          };
        };
        # WARNING : this might break container mount !
        # make container's root not root on host:
        extraFlags = [
          "-U"
          "--bind=${web.dataDir}"
        ];
      };

      # tools :
      environment.systemPackages = [
        pkgs.inetutils # let's have ping
      ];

      networking = {
        nat = {
          enable = web.container.useNat;
          internalInterfaces = [ "ve-+" ];
          externalInterface = web.container.interface;
          # Lazy IPv6 connectivity for the container
          enableIPv6 = true;
        };

        # Get bridge-ip with DHCP
        bridges."${web.container.bridge}".interfaces = [
          web.container.interface
        ];
        interfaces."${web.container.bridge}".useDHCP = true;
      };

      systemd = {
        # make sure the dataDir exists on Host
        tmpfiles.rules = [ "d ${web.dataDir} 0755 root root -" ];
        # delay container to happen after tmpfiles and network online
        services."container@${web.container.name}" = rec {
          wants = [
            "systemd-tmpfiles-setup.service"
            "network-online.target"
          ];
          after = wants;
        };
      };
    };
  };
}
