# default.nix
#	Base of modules
{ pkgs, config, lib, nixpkgs, system, ... }:
with builtins;
with lib;
let
  cfg = config.packages;

  # optiontype for overlays
  overlayType = mkOptionType {
    name = "nixpkgs-overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };
  overlaysType = types.listOf overlayType;

in {

  # interface : a way to expose settings
  options = {
    platform = let
      desc = "platform to build, should be the value of `pkgs.system`";
      values = [ "x86_64-linux" "aarch64-darwin" ];
      default = config.nixpkgs.hostPlatform.system;
    in mkOption {
      description = concatStringsSep "," [ desc "one of " (toString values) ];
      type = types.enum values;
      inherit default;
    };

    packages = {
      # allow select unfree packages
      unfreePackages = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "list of allowed unfree packages";
      };

      overlays = mkOption {
        type =
          overlaysType; # types.listOf types.listOf (types.functionTo types.attrs);
        default = [ ];
        description = "list of nixpks overlays";
      };
    };
  };

  config = {
    nix.registry.nixpkgs.flake = nixpkgs;
    nixpkgs = {
      overlays = cfg.overlays;
      config.allowUnfreePredicate = pkg: elem (getName pkg) cfg.unfreePackages;
    };
  };
}
