# default.nix
# default home config
# TODO : make it a re-usable user module
{ lib, pkgs, config, pkgs-latest, ... }: {

  # custom options
  options = with lib; {
    packages = {
      # nixpkgs.AllowUnfreePredicate
      unfree = mkOption {
        description = "list of unfree packages";
        type = types.listOf types.str;
        default = [ ];
      };
      # nixpkgs overlays
      overlays = mkOption {
        description = "list of overlays";
        type = types.listOf (mkOptionType {
          name = "nixpkgs-overlay";
          check = isFunction;
          merge = mergeOneOption;
        });
        default = [ ];
      };
    };
  };

  config = {
    # HM Setup
    nixpkgs.overlays = config.packages.overlays;
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.packages.unfree;
    programs.home-manager.enable = true;
  };
}
