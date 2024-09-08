# linux/boot.nix
{ config, lib, ... }:
let
  # shortcut:
  cfg = config.nixos.boot;
in
{
  options.nixos.boot = with lib; {
    # enable faster boot (disable many checks)
    fastBoot = mkEnableOption "Simplify boot process";
    # sleep mode
    sleep = mkEnableOption "allow sleep";
  };

  config = {

    boot = {
      plymouth.enable = true; # hide wall-of-text
      loader = {
        systemd-boot.enable = true; # use gummyboot for faster boot
        efi.canTouchEfiVariables = true; # may not be necessary
        systemd-boot.configurationLimit = 15;
      };
      consoleLogLevel = 3; # avoid useless errors
    };

    # Faster boot:
    systemd.services.NetworkManager-wait-online.enable = cfg.fastBoot;
    systemd.services.systemd-fsck.enable = cfg.fastBoot;

    # enable or disable sleep/suspend
    systemd.targets = lib.mkIf false {
      sleep.enable = cfg.sleep;
      suspend.enable = cfg.sleep;
      hibernate.enable = cfg.sleep;
      hybrid-sleep.enable = cfg.sleep;
    };
  };
}
