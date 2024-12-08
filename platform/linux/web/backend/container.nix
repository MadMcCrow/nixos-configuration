# module that enables making containers
{
  lib,
  config,
  pkgs,
  ...
}:
let
  # shortcut
  inherit (config.nixos) web;
  # avoid overlap of config
  inherit (config.system) stateVersion;

  containerOption =
    with lib;
    with lib.types;
    submodule {
      options = {
        dataDir = mkOption {
          description = "root directory for service";
          type = str;
        };
        config = mkOption {
          description = "container or bare-metal config";
          inherit
            ((options.containers.type {
              config = { };
              name = "option";
              options = { };
            }).config
            )
            type
            ;
        };
      };
    };

  # make container declaration simpler :
  mkContainer =
    _:
    { config, dataDir }:
    {
      # TODO : replace by a service that starts them all at once
      autoStart = false;
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      nixpkgs = pkgs.path;
      ephemeral = true;
      bindMounts = {
        "/" = {
          hostPath = dataDir;
          isReadOnly = false;
        };
      };
      config =
        x:
        (
          (config x)
          // {
            system = {
              inherit stateVersion;
            };
          }
        );
    };
in
{
  # interface
  options.nixos.web = with lib; {
    # no need to do bare metal !
    # if false everything is bare metal
    # useContainers = mkEnableOption "services in containers";
    # systemd containers
    services = mkOption {
      description = "services config that are run on the server";
      type = types.nullOr (types.attrsOf containerOption);
      default = null;
    };
  };

  # implementation
  config = lib.mkIf (web.enable && web.services != null) {
    # systemd-nspawn containers :
    containers = (lib.attrsets.mapAttrs mkContainer web.services);

    # make sure the dataDir exists on Host
    systemd = {

      #tmpfiles.rules = map (x: [ "d ${x.dataDir} 0755 root root -" ]) (builtins.attrValues web.services);

      # delay all containers to happen after tmpfiles.
      services =
        with builtins;
        (listToAttrs (
          map (x: {
            name = "container@${x}";
            value = {
              wants = [ "systemd-tmpfiles-setup.service" ];
              after = [ "systemd-tmpfiles-setup.service" ];
            };
          }) (attrNames web.services)
        ));

    };

    # full bare metal : NOT RECOMMENDED !
    # services = lib.mkIf (!web.useContainers) (
    #   lib.attrsets.mapAttrs (n: v: v.config.services) web.services
    # );
    # networking = lib.mkIf (!web.useContainers) (
    #   lib.attrsets.mapAttrs (n: v: v.config.networking) web.services
    # );
  };
}
