# apps/unfree.nix
# 	helper to allow unfree software
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  cfg = config.unfree;
  allowed = cfg.unfreePackages;
in {
  # interface
  options.unfree = {
    all = mkOption {
      type = types.bool;
      default = false;
      description = "Allow any unfree package";
    };

    unfreePackages = mkOption {
      type = types.listOf types.string;
      default = [ ];
      description = "list of allowed unfree packages";
    };
  };

  # unfree pa
  config = mkIf (cfg.all || allowed != [ ]) {
    nixpkgs.config = {
      allowUnfreePredicate = (pkg: builtins.elem (lib.getName pkg) allowed);
      allowUnfree = cfg.all;
    };
  };
}
