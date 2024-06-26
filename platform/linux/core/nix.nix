# default.nix
#	Base of modules
{ pkgs-latest, config, lib, nixpkgs, system, ... }:
let cfg = config.nixos.nix;
in {

  # interface :
  options.nixos.nix = with lib; {
    # allow select unfree packages
    unfreePackages = mkOption {
      description = "list of allowed unfree packages";
      type = with lib.types; listOf str;
      default = [ ];
    };
    # overlays to add to nix
    overlays = mkOption {
      description = "list of nixpks overlays";
      type = types.listOf (mkOptionType {
        name = "nixpkgs-overlay";
        check = isFunction;
        merge = mergeOneOption;
      });
      default = [ ];
    };
    # allow to override packages to add options
    overrides = mkOption {
      description = "set of package overrides";
      default = { };
    };
  };

  config = {
    nix = {
      # pin for nix2
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
      # pin for nix3
      registry.nixpkgs.flake = nixpkgs;

      package = pkgs-latest.nix;

      # security, might break macOS
      settings.allowed-users = [ "@wheel" ];

      # enable flakes and commands
      settings.experimental-features = [ "nix-command" "flakes" ];

      # substituters
      settings.substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://nixos-configuration.cachix.org"
      ];
      settings.trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixos-configuration.cachix.org-1:dmaMl2SX7/VRV1qAQRntZaNEkRyMcuqjb7H+B/2jlF0="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # GarbageCollection
      gc = {
        automatic = true;
        dates = "daily";
        persistent = true;
      };
      # detect files in the store that have identical contents,
      # and replaces them with hard links to a single copy.
      settings.auto-optimise-store = true;

      # this is linux only :
      optimise.automatic = true;
      optimise.dates = [ "daily" ];

      # serve nix store over ssh (the whole network can help each other)
      sshServe.enable = true;
    };

    nixpkgs = {
      # merged overlays
      overlays = cfg.overlays;

      # predicate from list
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) cfg.unfreePackages;

      # each functions gets its pkgs from here :
      config.packageOverrides = pkgs:
        (lib.mkMerge
          (builtins.mapAttrs (name: value: (value pkgs)) cfg.overrides));
    };

    # disable documentation (don't download, online is always up to date)
    documentation.nixos.enable = false;

    # add a shortcut script :
    environment.systemPackages = [
      (pkgs-latest.writeShellApplication {
        name = "nixos-update";
        runtimeInputs = [ pkgs-latest.nixos-rebuild ];
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
          ${lib.getExe pkgs-latest.nixos-rebuild} "$MODE" \
          --flake ${config.system.autoUpgrade.flake}#${config.networking.hostName}
          exit $?
        '';
      })
    ];

    system.autoUpgrade = {
      enable = true;
      operation = "boot"; # just upgrade :)
      flake = "github:MadMcCrow/nixos-configuration";
      # reboot at night :
      allowReboot = true;
      rebootWindow = {
        lower = "03:00";
        upper = "05:00";
      };
      # do it everyday
      persistent = true;
      dates = "daily";
    };
  };
}
