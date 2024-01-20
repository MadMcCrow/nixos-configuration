# core/upgrade.nix
# nixos auto-upgrade settings
# TODO : move to nix folder and support darwin too
{ pkgs, lib, config, ... }:
let
  # shortcut
  cfg = config.nixos.upgrade;

  # this flake :
  flake = "MadMcCrow/nixos-configuration";

  # custom command :
  nixos-update = pkgs.writeShellApplication {
    name = "nixos-update";
    runtimeInputs = [ pkgs.nixos-rebuild ];
    text = ''
      if [ "$USER" != "root" ]; then
        echo "Please run nixos-update as root or with sudo"; exit 2
      fi
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake github:${flake}#
      exit $?
    '';
  };

in {
  # interface :
  options.nixos.upgrade = {
    enable = lib.mkEnableOption "enable auto upgrade" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      inherit flake;
      allowReboot = true;
      rebootWindow = {
        lower = "03:00";
        upper = "05:00";
      };
      persistent = true;
      dates = "daily";
    };

    hardware = {
      enableRedistributableFirmware = true;
      cpu.amd = { updateMicrocode = true; };
      cpu.intel = { updateMicrocode = true; };
    };

    environment.systemPackages = [ nixos-update ];

  };
}
