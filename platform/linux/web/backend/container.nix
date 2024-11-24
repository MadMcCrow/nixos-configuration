# module that enables making containers
{ lib, config, pkgs, ... } :
let
stateVersion = config.system.stateVersion;
mkContainer = {config, dataPath, ...} :
{
      autoStart = true;
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      nixpkgs = pkgs.path;
      ephemeral = true;
      bindMounts = {
        "/" = {
          hostPath = "${dataPath}";
          isReadOnly = false;
        };
      };
      config = config // {
        system  = { inherit stateVersion; };
      };
    };
in
{
  # interface
  options.nixos.web = with lib; {
    # if false everything is bare metal
    useContainers = mkEnableOption "services in containers" // {default = true;};
    # systemd containers
    containers =  mkOption {
      description = "config for the container";
      type = types.attrset;
    };
  };

  # implementation
  config = {
    containers = lib.mkIf useContainers (lib.attrsets.mapAttrs (n: v: mkContainer v) config.nixos.web.containers);
  };
  # TODO : DO FULL BARE METAL !
}
