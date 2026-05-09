{ config, nonlib, pkgs, lanzaboote, ... }:
with nonlib; {
  imports = [ lanzaboote.nixosModules.lanzaboote ];
} // nonOS __curPos config
{
  nonOptions = with nonlib; {
    secureboot.enable = mkDisableOption "secureboot";
  };

  # implementation
  nonConfig = cfg: {
    boot = {
      initrd.systemd = {
        enable = true;
        fido2.enable = true;
      };
      tmp.cleanOnBoot = true;
      loader = {
        systemd-boot = {
          enable = true;
          editor = false;
          configurationLimit = 5;
        };
        grub.enable = false;
      };
    lanzaboote = {
        inherit (cfg.secureboot) enable;
        pkiBundle = "${config.nonOS._persist}/secureboot";
        configurationLimit = 5;
      };
      plymouth.enable = true;
      consoleLogLevel = 3;
    };
    environment.defaultPackages = with pkgs; [
      sbctl
      tpm-luks
      tpm2-tss
      libfido2
    ];
  };
}
