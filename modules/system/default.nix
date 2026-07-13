# system.nix
# define the update process in NonOS
inputs @ {
  config,
  nonOS,
  lib,
  pkgs,
  ...
}:
with lib;
let
  os = nonOS __curPos inputs;
in
{
  options = os.options {
    # secureboot
    secureboot.enable = mkEnableOption "secureboot" // {default = true;};
    # yubikey,onlykey, etc..
    fido.enable = mkEnableOption """
      FIDO2 : https://nixos.org/manual/nixos/stable/#sec-luks-file-systems-fido2
    """;
  };

  config = mkIf os.enabled {
    boot = {
      initrd.systemd = {
        enable = mkDefault true;
        fido2.enable = mkDefault os.cfg.fido;
      };
      tmp.cleanOnBoot = mkDefault true;
      loader = {
        systemd-boot.enable = mkForce (!os.cfg.secureboot.enable);
        grub.enable = mkForce false;
      };
      lanzaboote = {
        inherit (os.cfg.secureboot) enable;
        pkiBundle = "${config._persist}/secureboot";
        configurationLimit = 5;
      };
      plymouth.enable = mkDefault true;
      consoleLogLevel = mkDefault 3;
    };

    environment = {
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

      systemPackages = [nonpkgs.os];
      defaultPackages = with pkgs; [
        openssl
        dnsutils
        sbctl
        tpm-luks
        tpm2-tss
        nmap
      ] ++ (optionals [libfido2]);
    };

    hardware.cpu = mkDefault {
      # include both microcode.
      # it makes for a bigger initrd
      # but it does not really matter much
        amd.updateMicrocode = true;
        intel.updateMicrocode = true;
    };

    programs = {
      # zsh is the far superior shell in my opinion
      zsh.enable = mkDefault true;
      bash.enable = mkDefault false;
    };

    services = {
      openssh = mkDefault {
      enable = true;
      ports = [ 8323 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = attrNames config.users.users;
      };
    };

    system = {
      stateVersion = mkDefault "26.05";
      nixos.label = "${os.name}";
      nixos.variantName = "${os.name}";
    };

    time = mkDefault {
       # we default to Paris
      timeZone = "Europe/Paris";
    };

    users = {
      defaultUserShell =  mkdefault pkgs.zsh;
      # enable mutable users if no user is set to admin
      mutableUsers = !(any (x: x.admin == true) (attrValues config.users.users));
    };
  };
}
