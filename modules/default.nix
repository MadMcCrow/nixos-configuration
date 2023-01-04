# default.nix
#	Collection of modules to enable
#	Add your NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
#
# unfree packages : use list to have a single unfree predicate
#
{ pkgs, config, nixpkgs, lib, ... }:
with builtins;
with lib;
let

  cfg = config.unfree;
  allowed = cfg.unfreePackages;
in {

  # interface : option for unfree modules
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

  # unfree packages Predicate
  config = mkIf (cfg.all || allowed != [ ]) {
    nixpkgs.config = {
      allowUnfreePredicate = (pkg: builtins.elem (lib.getName pkg) allowed);
      allowUnfree = cfg.all;
    };
  };

  # submodules
  imports = [ ./apps ./audio ./nixos ./desktop ./input ./users ];
}
