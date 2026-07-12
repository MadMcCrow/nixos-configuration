# system.nix
# define the update process in NonOS
inputs @ {
  config,
  nonOS,
  lib,
  pkgs,
  nonlib,
  nonpkgs,
  ...
}:
with lib;
let
  os = nonOS __curPos inputs;
  flake_url = "https://github.com/MadMcCrow/nonOS";
in
{
  options = os.options {
    # global option to allow unfree packages
    _unfreePackages = mkStrListOption "accepted unfree packages" [ ];}
    # enable secureboot
    secureboot.enable = mkDisableOption "secureboot";

    gpu = mkOptioion
  };

  config = mkIf os.enabled {


    boot = {
      initrd.systemd = {
        enable = true;
        fido2.enable = true;
      };
      tmp.cleanOnBoot = true;
      loader = {
        systemd-boot.enable = mkForce (!os.cfg.secureboot.enable);
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
        libfido2
        nmap
      ];
    };

    hardware = {
      cpu = {
        amd.updateMicrocode = true;
        intel.updateMicrocode = true;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    # TODO !
    networking = {
      # hostname is a mandatory key.
    };

    nix = {
      nixPath = [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "/nix/var/nix/profiles/per-user/root/channels"
        "nixpkgs=flake:nixpkgs"
      ];

      package = pkgs.lix;

      settings = {
        # keep flake and commands
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        # cache providers
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
          "https://cachix.cachix.org"
          "https://nixpkgs.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
          "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        ];

      };
    };


    nixpkgs = {
      # help other modules
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config._unfreePackages;
    };

    programs = {
      zsh.enable = true;
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
