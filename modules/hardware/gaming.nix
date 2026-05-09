# hardwaregaming.nix
# module to support gaming hardware
{ config, nonlib, nonOS, ... }:
nonOS __curPos config
{
  nonOptions = with nonlib; {
    steam-controller = mkDisableOption "steam controller support";
    xbox-one-controller = mkDisableOption "xbox controller support";
  };

  nonConfig = cfg: {
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
