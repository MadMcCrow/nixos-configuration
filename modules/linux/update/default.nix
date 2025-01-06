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
with pkgs;
let
  nixos-enroll = substitute {
    name = "nixos-enroll";
    src = ./nixos-enroll.sh;
    dir = "bin";
    buildInputs = [
      libfido2
      systemd
    ];
    isExecutable = true;
    substitutions = [
      "--replace"
      "$(which fido2-token)"
      "${libfido2}/bin/fido2-token"
      "--replace"
      "$(which systemd-cryptenroll)"
      "${systemd}/bin/systemd-cryptenroll"
      "--repkace"
      "DISKS=()"
      (lib.toShellVar (map (v: v.device) (builtins.attrValues config.boot.initrd.luks.devices)))
    ];
  };

  # All in one command :
  nixos-update = substitute {
    name = "nixos-update";
    src = ./nixos-update.sh;
    dir = "bin";
    buildInputs = [
      nixos-enroll
      nixos-rebuild
    ];
    isExecutable = true;
    substitutions = [
      "--replace"
      "flake"
      config.nixos.update.flake
      "--subst-var-by"
      "host"
      config.networking.hostName
      "--replace"
      "$(which nixos-rebuild)"
      (lib.getBin nixos-rebuild)
      "--subst-var-by"
      "disks"
      "--subst-var-by"
      "pcrs"
      (lib.strings.concatStringsSep "+" (map builtins.toString config.nixos.secureboot.pcrs))
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
