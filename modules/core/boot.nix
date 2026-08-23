# boot.nix
# define how nonOS boots
nonOS:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with nonOS;
let
  os = mod "boot" config;
in
with os;
{
  imports = [ nonOS.inputs.lanzaboote.nixosModules.lanzaboote ];

  options = mkOptions {
    # enable secureboot
    secureboot.enable = mkEnableOption "secureboot" // {
      default = true;
    };
    # yubikey,onlykey, etc..
    fido.enable = mkEnableOption "FIDO2 : https://nixos.org/manual/nixos/stable/#sec-luks-file-systems-fido2";
  };

  config = mkConfig {
    boot = {
      initrd.systemd = {
        enable = true;
        fido2.enable = os.cfg.fido.enable;
      };
      tmp.cleanOnBoot = true;
      loader = {
        systemd-boot.enable = !os.cfg.secureboot.enable;
        grub.enable = false;
      };
      lanzaboote = {
        inherit (os.cfg.secureboot) enable;
        pkiBundle = "${cfg._dir}/secureboot";
        configurationLimit = 5;
      };
      plymouth.enable = true;
      consoleLogLevel = 3;
    };

    environment = {
      defaultPackages =
        with pkgs;
        [
          openssl
          dnsutils
          sbctl
          # tpm-luks -> removed due to lack of maintenance
          tpm2-tss
          nmap
        ]
        ++ (optionals cfg.fido.enable [ libfido2 ]);
    };

    hardware = {
      # we could include both microcodes
      # but the hardware detection can give you the correct param
      # cpu.amd.updateMicrocode = true;
      # cpu.intel.updateMicrocode = true;
      # we just need this to be enabled :
      enableRedistributableFirmware = true;
      firmware = [ pkgs.linux-firmware ];
    };
  };
}
