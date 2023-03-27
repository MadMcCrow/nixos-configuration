# darwin/default.nix
# 	Nix Darwin (MacOS) Specific settings
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.darwin;
  submodules = [ ./pam.nix ];
in {
  options.darwin.enable = mkEnableOption (mdDoc "Darwin (MacOS)") // {
    default = false;
  };
  imports = submodules;
}
