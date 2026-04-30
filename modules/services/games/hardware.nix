# hardware.nix
# module to support gaming hardware
{ config, lib, ... }:
let
  cfg = config.games.hardware;
  mkDisableOption = d: lib.mkEnableOption d // { enable = true; };
in {

  options.nonOS.games.hardware = {
    steam-controller = mkDisableOption "steam controller support";
    xbox-one-controller = mkDisableOption "steam controller support";
  };

  config = {
    # enable the nixos hardware modules
    hardware = {
      xone.enable = cfg.xbox-one-controller;
      steam-hardware.enable = cfg.steam-controller;
    };

    programs.steam.extest.enable = cfg.steam-controller;

    # depends on the "linux" module !
    _nonOS.unfreePackages = with lib.lists;
      (optional cfg.steam-controller "steam-original")
      ++ (optional cfg.xbox-one-controller "xow_dongle-firmware");
  };
}
