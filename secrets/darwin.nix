{ config, pkgs, lib, pycnix, ... }:
let
  cfg = config.secrets;
  # the various scripts for nixage
  nixage-scripts = import ./scripts.nix { inherit pkgs pycnix; };
in {
  # pkgs :
  environment.systemPackages = builtins.AttrValues nixage-scripts;

}
