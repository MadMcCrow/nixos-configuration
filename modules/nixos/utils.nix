# nixos/utils.nix
# 	Set of linux tools for sys-admin
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.utils;
in {
  # interface
  options.nixos.utils.enable = mkEnableOption (mdDoc "nixos tools") // {
    default = true;
  };
  # config
  config = lib.mkIf (nos.enable && cfg.enable) {

    # Packages
    environment = {
      systemPackages = with pkgs; [ pciutils usbutils ];
    };
  };
}