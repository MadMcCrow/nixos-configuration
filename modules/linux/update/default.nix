# linux/update.nix
# add script and a service to perform unattended update in the best of ways
# TODO :
# - disable/wrap nixos-rebuild and replace by build and apply to avoid confusion
{
  pkgs,
  lib,
  config,
  ...
}:
let
  # update config and enroll the new tpm keys !
  nixos-update =
    with pkgs;
    substitute {
      name = "nixos-update";
      src = ./nixos-update.sh;
      dir = "bin";
      buildInputs = [
        systemd
        nixos-rebuild
      ];
      isExecutable = true;
      substitutions = [
        "--subst-var-by"
        "flake"
        config.nixos.update.flake
        "--subst-var-by"
        "host"
        config.networking.hostName
        "--subst-var-by"
        "systemd"
        (lib.getBin systemd)
        "--subst-var-by"
        "nixos-rebuild"
        (lib.getBin nixos-rebuild)
        "--subst-var-by"
        "disks"
        (lib.strings.escapeShellArgs (
          map (v: v.device) (
            builtins.attrValues config.boot.initrd.luks.devices
          )
        ))
        "--subst-var-by"
        "pcrs"
        (lib.strings.concatStringsSep "+" (
          map builtins.toString config.nixos.secureboot.pcrs
        ))
      ];
      #TODO #installManPage #./nixos-update.8
      # installShellCompletion --bash ${./_nixos-rebuild}
      postInstall = "";
      meta = {
        description = "wrapper around nixos-rebuild";
        license = lib.licenses.mit;
        mainProgram = "nixos-update";
      };
    };
in
{
  config = lib.mkIf config.nixos.enable {
    # add our tool to the configuration
    environment.systemPackages = [ nixos-update ];
    # TODO :
    # Add systemd.services."auto-update" 
  };
}
