# All the things that must be persistant across reboots
{ config, lib, pkgs, modulesPath, ... }: {

  # symlinks :
  environment.etc = {

    # Nixos configuration files (ie. this)
    "nixos" = {
       source = "/nix/persist/etc/nixos/";
       mode = "0664";
    };

    # machine-id is used by systemd for the journal, if you don't
    # persist this file you won't be able to easily use journalctl to
    # look at journals for previous boots.
    "machine-id" = {
       source = "/nix/persist/etc/machine-id";
       mode = "0664";
    };

    # some NetworkManager configuration
    "NetworkManager/system-connections".source =
      "/nix/persist/etc/NetworkManager/system-connections/";

  };

}

