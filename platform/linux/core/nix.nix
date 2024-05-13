# default.nix
#	Base of modules
{ pkgs-latest, config, lib, nixpkgs, system, ... }:
let
  cfg = config.packages;

  # optiontype for overlays
  overlaysType = with lib;
    let
      subType = mkOptionType {
        name = "nixpkgs-overlay";
        check = isFunction;
        merge = mergeOneOption;
      };
    in types.listOf subType;

in {

  # interface : a way to expose settings
  options = {
    packages = {
      # allow select unfree packages
      unfreePackages = lib.mkOption {
        description = "list of allowed unfree packages";
        type = with lib.types; listOf str;
        default = [ ];
      };

      overlays = lib.mkOption {
        description = "list of nixpks overlays";
        type =
          overlaysType; # types.listOf types.listOf (types.functionTo types.attrs);
        default = [ ];
      };

      overrides = lib.mkOption {
        description = "set of package overrides";
        default = { };
      };
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
  };
}
