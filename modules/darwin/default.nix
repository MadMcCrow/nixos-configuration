# darwin/default.nix
# 	Nix Darwin (MacOS) Specific settings
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.darwin;
  submodules = [ ./pam.nix ./nix.nix ];
in {
  options.darwin.enable = mkEnableOption (mdDoc "Darwin (MacOS)");
  imports = submodules;
}
