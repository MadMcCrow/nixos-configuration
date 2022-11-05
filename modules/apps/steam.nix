# gaming/steam.nix
#	Make steam works on your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let cfg = config.apps.steam;
in {
  options.apps.steam = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable steam, the PC Gaming platform
      '';
    };
  };

  # import unfree to allow programs
  imports = [ ../unfree.nix ];

  config = mkIf cfg.enable {

    hardware.steam-hardware.enable = true; # Steam udev rules
    # steam 
    programs.steam = {
      enable = true;
      remotePlay.openFirewall =
        true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall =
        true; # Open ports in the firewall for Source Dedicated Server
    };

    unfree.unfreePackages =
      [ "steam" "steam-original" "steam-runtime" "steam-run" ];

    # Steam user
    users.users.steam = {
      isSystemUser = true;
      home = "/home/steam";
      useDefaultShell = false;
      createHome = false;
      group = "users"; # allow users to access steam folder
      homeMode = "770";
    };
  };
}

