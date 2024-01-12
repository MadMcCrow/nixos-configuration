# secrets/nixos
# Nixos configuration of nixage secret management
# TODO : 
#       - update keys as a service
{ config, pkgs, lib, pycnix, ... }:
with builtins;
let
  cfg = config.secrets;
  # the various scripts for nixage
  nixage = import ../nixage.nix { inherit pkgs lib pycnix config; };
  # a function to make services
  mkService = import ./service.nix { inherit pkgs lib config nixage; };

in {
  # options defined separately
  imports = [ ../options.nix ];

  # linux specific
  options.secrets = {
    tmpfs = {
      enable = lib.mkEnableOption "Use tmpfs for decrytion" // {
        default = true;
      };
      mountPoint = lib.mkOption {
        default = "/nix/secretfs";
        description = lib.mdDoc "path of tmpfs for secret decryption";
      };
    };
  };

  # nixos apply secrets
  config = lib.mkIf cfg.enable {

    # pkgs :
    environment.systemPackages = (attrValues nixage);

    # TMPFS for secrets (no write to disk !)
    fileSystems."${cfg.tmpfs.mountPoint}" = lib.mkIf cfg.tmpfs.enable {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=750" ];
    };

    # tmpfs rules to create and remove file
    systemd.tmpfiles.rules =
      (map (x: "d ${dirOf x.decrypted} 0750 ${x.user} ${x.group} -")
        (attrValues cfg.secrets));

    # auto apply secrets service
    systemd.services = (mapAttrs mkService cfg.secrets);

  };
}
