{
  config,
  lib,
  nonlib,
  pkgs,
  lanzaboote,
  ...
}:
let
  os = nonOS {__curpos, config, options};
in
{
  # options
  options = os.options {
    secureboot.enable = mkDisableOption "secureboot";
  };

  # implementation
  config = {
      boot = {
        initrd.systemd = {
          enable = true;
          fido2.enable = true;
        };
        tmp.cleanOnBoot = true;
        loader = {
          systemd-boot.enable = mkForce (!cfg.secureboot.enable);
          grub.enable = mkForce false;
        };
        lanzaboote = {
          inherit (cfg.secureboot) enable;
          pkiBundle = "${globals.persist}/secureboot";
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
