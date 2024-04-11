# default.nix
#	Base of modules
{ pkgs, config, lib, nixpkgs, ... }:
let
  # shortcut 
  cfg = config.darwin;

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
  options.darwin = {
    packages = {
      # allow select unfree packages
      unfreePackages = lib.mkOption {
        description = "list of allowed unfree packages";
        type = with lib.types; listOf str;
        default = [ ];
      };
      overlays = lib.mkOption {
        description = "list of nixpks overlays";
        type = overlaysType;
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

      package = pkgs.nix;

      settings = {
        # keep flake and commands
        experimental-features = [ "nix-command" "flakes" ];

        # cache providers
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
          "https://nixos-configuration.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nixos-configuration.cachix.org-1:dmaMl2SX7/VRV1qAQRntZaNEkRyMcuqjb7H+B/2jlF0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # TODO MAYBE ONLY HAVE @admin
        trusted-users = [ "@admin" ];
        allowed-users = [ "@wheel" ];

        # detect files in the store that have identical contents,
        # and replaces them with hard links to a single copy.
        auto-optimise-store = true;

      };
      # GarbageCollection
      gc.automatic = true;

      # redo what's in settings + add x86 to M1 macs
      extraOptions = ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
    };

    nixpkgs = {
      # merged overlays
      overlays = cfg.packages.overlays;

      # predicate from list
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) cfg.packages.unfreePackages;

      # each functions gets its pkgs from here :
      config.packageOverrides = pkgs:
        (lib.mkMerge (builtins.mapAttrs (name: value: (value pkgs))
          cfg.packages.overrides));
    };

    programs.nix-index.enable = true;
    services.nix-daemon.enable = true;
  };
}
