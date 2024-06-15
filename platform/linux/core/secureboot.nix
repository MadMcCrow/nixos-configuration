# secureboot.nix
# module to use secureboot, full disk encryption
# and TPM enrollment for keys.
{ lib, config, pkgs, ... }:
let
  # shortcut
  cfg = config.nixos.secureboot;
in {
  # interface
  options.nixos.secureboot = with lib; {
    enable = mkEnableOption ''
      enable secure boot.
      Only set to true when you've completed the necessary steps !
      Please follow https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
      You can then use luks devices passwordless :
      `sudo systemd-cryptenroll /dev/$DISK --tpm2-device=auto --tpm2-pcrs=0+2+7`
      see https://www.reddit.com/r/NixOS/comments/xrgszw/nixos_full_disk_encryption_with_tpm_and_secure/ 
      for details !
    '';
  };

  config = {
    # make etc/secureboot persistant :
    fileSystems."/etc/secureboot" = {
      device = "/nix/persist/secureboot";
      options = [ "bind" ];
      neededForBoot = true;
    };

    environment.systemPackages = [
      # For debugging and troubleshooting Secure Boot.
      pkgs.sbctl
    ];

    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time.
    boot = lib.mkIf cfg.enable {
      loader.systemd-boot.enable = lib.mkForce false;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
