# system.nix
# define the update process in NonOS
inputs@{
  config,
  nonOS,
  lib,
  pkgs,
  ...
}:
with lib;
let
  os = nonOS __curPos inputs;
  mkPrio = mkOverride 990; # mkDefault but higher priority
in
{
  options = os.mkOptions {
    # rename the OS
    customise = mkEnableOption "customise nixOS to ${os.name}" // {
      default = true;
    };
    # enable secureboot
    secureboot.enable = mkEnableOption "secureboot" // {
      default = true;
    };
    # yubikey,onlykey, etc..
    fido.enable =
      mkEnableOption ""
        "
      FIDO2 : https://nixos.org/manual/nixos/stable/#sec-luks-file-systems-fido2
    "
        "";
  };

  config = os.mkConfig {
    boot = {
      initrd.systemd = {
        enable = true;
        fido2.enable = os.cfg.fido;
      };
      tmp.cleanOnBoot = mkPrio true;
      loader = {
        systemd-boot.enable = mkForce (!os.cfg.secureboot.enable);
        grub.enable = mkForce false;
      };
      lanzaboote = mkPrio {
        inherit (os.cfg.secureboot) enable;
        pkiBundle = "${config._persist}/secureboot";
        configurationLimit = 5;
      };
      plymouth.enable = mkPrio true;
      consoleLogLevel = mkPrio 3;
    };

    environment = mkPrio {
      etc."os-release".text = ''
        NAME="${os.name}"
        PRETTY_NAME="${os.name}"
        VERSION_ID="${os.version}"
        VERSION="${os.version}-${os.status}"
        ID=nixos
        BUILD_ID="rolling"
        ANSI_COLOR="1;32"
        HOME_URL="${flake_url}"
        SUPPORT_URL="${flake_url}"
        BUG_REPORT_URL="${flake_url}/issues"
      '';

      systemPackages = [ nonpkgs.os ];
      defaultPackages =
        with pkgs;
        [
          openssl
          dnsutils
          sbctl
          tpm-luks
          tpm2-tss
          nmap
        ]
        ++ (optionals [ libfido2 ]);
    };

    hardware = {
      # we could include both microcodes
      # but the hardware detection can give you the correct param
      # cpu.amd.updateMicrocode = true;
      # cpu.intel.updateMicrocode = true;
      firmware = [ pkgs.linux-firmware ];
    };

    programs = {
      # zsh is the far superior shell in my opinion
      zsh.enable = mkPrio true;
      bash.enable = mkPrio false;
    };

    services = {
      openssh = mkPrio {
        enable = true;
        ports = [ 8323 ];
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = attrNames config.users.users;
        };
      };
    };

    system = {
      # let the user specify the state version themselves
      # but forgetting defining it shouldn't matter
      stateVersion = mkDefault "26.05";
      # We customise the
      nixos.label = "${os.name}";
      nixos.variantName = "${os.name}";
    };

    time = {
      # we default to Paris
      timeZone = mkPrio "Europe/Paris";
    };

    users = {
      defaultUserShell = mkPrio pkgs.zsh;
      # enable mutable users if no user is set to admin
      mutableUsers = !(any (x: x.admin == true) (attrValues config.users.users));
    };
  };
}
