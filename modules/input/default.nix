# input/default.nix
#	Collection of modules to enable
{ pkgs, config, nixpkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  cfg = config.input;
  submodules = [ ./ratbag.nix ./input-remapper.nix ./xone.nix ];
in {
  options.input.enable = mkEnableOption (mdDoc "custom inputs") // {
    default = true;
  };
  imports = submodules;
}
