# darwin/default.nix
# 	Nix Darwin (MacOS) specific apps to use :
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let cfg = config.darwin.apps;
in {
  options.darwin.apps.enable = mkEnableOption (mdDoc "Darwin (MacOS)");
  # TODO : config
}
