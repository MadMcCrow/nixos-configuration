# All the things that must be persistant across reboots
{ config, lib, pkgs, modulesPath, ... }: {

  # symlinks :
  environment.etc = {

    # Nixos configuration files (ie. this)
    "nixos".source = "/nix/persist/etc/nixos/";

    # some NetworkManager configuration
    "NetworkManager/system-connections".source =
      "/nix/persist/etc/NetworkManager/system-connections/";

  };

}

