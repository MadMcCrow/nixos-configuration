# default.nix
#	Base of modules
{ pkgs, config, lib, nixpkgs, ... }:
with builtins;
with lib;
let
  cfg = config.packages;
  
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.unfreePackages;

  # optiontype for overlays
  overlayType = mkOptionType {
    name = "nixpkgs-overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };
  overlaysType = types.listOf overlayType;
  
in {

  # interface : option for unfree modules
  options = {
    
    packages = {
      # allow select unfree packages
      unfreePackages = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "list of allowed unfree packages";
        };
      # Allow having overides in multiple modules
      overrides = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
        description =
          "list of package overrides packages formatted as {a = a.OverrideAttr(...)}";
      };
      overlays = mkOption {
        type =  overlaysType;  #types.listOf types.listOf (types.functionTo types.attrs);
        default = [ ];
        description = "list of nixpks overlays";
      };
    };
  };

  # submodules
  imports = [ ./nixos ./darwin ];

  config = {
    nix.registry.nixpkgs.flake = nixpkgs;
    nixpkgs = {
      overlays = cfg.overlays;
      config = {
        inherit allowUnfreePredicate;
        #packageOverrides = pkgs: listToAttrs (mapAttrs (name: value: { inherit name value; }) cfg.overrides);
      };
    };
  };
}
