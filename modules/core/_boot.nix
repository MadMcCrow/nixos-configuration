{
  config,
  lib,
  nonOS,
  pkgs,
  lanzaboote,
  ...
}:
with lib;
with nonlib;
let
os = nonOS __curPos {inherit config;};
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
          inherit (os.cfg.secureboot) enable;
          pkiBundle = "${config._persist}/secureboot";
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
