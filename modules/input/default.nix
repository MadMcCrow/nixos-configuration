# input/default.nix
#	Collection of modules to enable
{ pkgs, config, nixpkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  cfg = config.inputs;
  submodules = [ ./ratbag.nix ./input-remapper.nix ./xone.nix ];
in {
  option.inputs.enable = mkEnableOption {
    name = mdDoc "inputs";
    default = true;
  };
  imports = if cfg.enable then submodules else [ ];
}
