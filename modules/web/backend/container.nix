# module that enables making containers
{
  lib,
  config,
  pkgs,
  ...
}:

#### TODO : wait for network-online.target
# use :
# system.switch.enable = false
let
  # shortcut
  inherit (config.nixos) web;

  serviceOption =
    with lib;
    with lib.types;
    submodule {
      options = {
        containerize = mkEnableOption "containerization of service";
        subDir = mkOption {
          description = "directory for service (relative to web server root)";
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
      type = types.nullOr (types.attrsOf serviceOption);
      default = null;
    };
    # directory that contains all the web server data
    dataDir = mkOption {
      description = "path to root for web server";
      type = types.str;
      default = "/www";
    };
  };

  # implementation
  config = lib.mkIf web.enable {
    # systemd-nspawn containers :
    containers."web" = {
      autoStart = true;
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      nixpkgs = pkgs.path;
      ephemeral = true;
      tmpfs = [
        "/tmp"
        # TODO !!
      ];
      bindMounts = {
        "/" = {
          hostPath = web.dataDir;
          isReadOnly = false;
        };
      };
      config = _: {
        containers."test" = {
          autoStart = true;
          privateNetwork = false;
          nixpkgs = pkgs.path;
          ephemeral = true;
          tmpfs = [
            "/tmp"
            # TODO !!
          ];
          bindMounts = {
            "/" = {
              hostPath = "/www";
              isReadOnly = false;
            };
          };
          config = _: { programs.zsh.enable = true; };
        };
        system = {
          inherit stateVersion;
        };
      };
    };

    # make sure the dataDir exists on Host
    systemd = {

      #tmpfiles.rules = map (x: [ "d ${x.dataDir} 0755 root root -" ]) (builtins.attrValues web.services);

      # delay all containers to happen after tmpfiles.
      # services =
      #   with builtins;
      #   (listToAttrs (
      #     map (x: {
      #       name = "container@${x}";
      #       value = {
      #         wants = [ "systemd-tmpfiles-setup.service" ];
      #         after = [ "systemd-tmpfiles-setup.service" ];
      #       };
      #     }) (attrNames web.services)
      #   ));

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
