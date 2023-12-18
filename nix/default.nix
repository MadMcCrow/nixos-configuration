# default.nix
#	Base of modules
{ pkgs, config, lib, nixpkgs, system, ... }:
with builtins;
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
    platform = let
      desc = "platform to build, should be the value of `pkgs.system`";
      values = [ "x86_64-linux" "aarch64-darwin" ];
      default = config.nixpkgs.hostPlatform.system;
    in lib.mkOption {
      description = concatStringsSep "," [ desc "one of " (toString values) ];
      type = lib.types.enum values;
      inherit default;
    };

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

      package = pkgs.nix;

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

    };
    nixpkgs = {
      # merged overlays
      overlays = cfg.overlays;

      # predicate from list
      config.allowUnfreePredicate = pkg:
        elem (lib.getName pkg) cfg.unfreePackages;

      # each functions gets its pkgs from here :
      config.packageOverrides = pkgs:
        (lib.mkMerge (mapAttrs (name: value: (value pkgs)) cfg.overrides));
    };
  };
}
