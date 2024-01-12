{ config, pkgs, lib, pycnix, ... }:
let
  cfg = config.secrets;
  # the various scripts for nixage
  nixage = import ./nixage.nix { inherit pkgs pycnix config lib; };
in {
  # pkgs :
  environment.systemPackages = builtins.AttrValues nixage-scripts;

}
