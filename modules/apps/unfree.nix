# apps/unfree.nix
# 	helper to allow unfree software
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  cfg = config.unfree;
  allowed = cfg.allowedUnfree;
in {
  # interface
  options.unfree.allowedUnfree = mkOption {
    type = types.listOf types.string;
    default = [ ];
  };

  config.nixpkgs.config.allowUnfreePredicate =
    (pkg: builtins.elem (lib.getName pkg) allowed);
}
