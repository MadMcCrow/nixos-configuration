# configuration for steam etc ...
{ config, lib, pkgs, modulesPath, ... }: {

  hardware.steam-hardware.enable = true; # Steam udev rules

  # steam 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-runtime"
    ];

  # Steam user
  users.users.steam = {
    isSystemUser = true;
    home = "/home/steam";
    useDefaultShell = false;
    createHome = false;
    group = "users"; # allow users to access steam folder
    homeMode = "770";
  };
}

