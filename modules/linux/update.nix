# linux/update.nix
# add script and a service to perform unattended update in the best of ways
# TODO :
# - disable/wrap nixos-rebuild and replace by build and apply to avoid confusion
{pkgs, lib, config, ...} :
    with pkgs;
let
 # auto-enroll app
  nixos-enroll-tpm = writeShellApplication {
      name = "nixos-enroll-tpm";
      runtimeInputs = [ systemd ];
      text = lib.strings.concatMapStringsSep "\n" (
        v:
        "${systemd}/bin/systemd-cryptenroll  ${v.device} --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+1+7+11"
      ) (builtins.attrValues config.boot.initrd.luks.devices);
    };

   nixos-update = writeShellApplication {
            name = "nixos-update";
            runtimeInputs = [ nixos-rebuild ];
            text = ''
              if [ -z "$1" ]
              then
                MODE=$1
              else
                MODE="switch"
              fi
              if [ "$USER" != "root" ]; then
                echo "Please run nixos-update as root or with sudo"; exit 2
              fi
              ${lib.getExe nixos-rebuild} "$MODE" \
              --flake ${config.system.autoUpgrade.flake}#${config.networking.hostName}
              exit $?
            '';
          };
in
{
  config = lib.mkIf config.nixos.enable {
    environment.defaultPackages = [ nixos-enroll-tpm nixos-update ];
  };
}