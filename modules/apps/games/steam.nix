# gaming/steam.nix
#	Make steam works on your system
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  # config interface
  gms = config.apps.games;
  cfg = gms.steam;
  arg = cfg.cliArgs;
  # wrapped steam bin with args
  steam-wrapped = pkgs.steam.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs or [ ] ++ [ pkgs.makeWrapper ];
    postInstall = oldAttrs.postInstall or "" + ''
      wrapProgram $out/bin/hello \
        --add-flags "${arg}"
    '';
  });

in {
  #interface
  options.apps.games.steam = {
    enable = mkOption {
      type = types.bool;
      default = gms.enable;
      description = ''
        enable steam, the PC Gaming platform
      '';
    };
    cliArgs = mkOption {
      type = types.str;
      default = "-gamepadui";
      description = ''
        command line arguments for running steam
      '';
    };
  };
  # config
  config = mkIf cfg.enable {
    hardware.steam-hardware.enable = true; # Steam udev rules
    # steam 
    programs.steam = {
      enable = true;
      package = steam-wrapped;
      # Open ports in the firewall for Steam Remote Play and Source Dedicated Server
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    unfree.unfreePackages =
      [ "steam" "steam-original" "steam-runtime" "steam-run" ];

    # Steam user (not mandatory)
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

