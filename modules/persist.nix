# persist.nix
# 	opt-in persistance.
#	All the things that must not be erased across reboots
{config}: {

  # symlinks :
  environment.etc = {

    # Nixos configuration files (ie. this)
    "nixos".source = "/nix/persist/etc/nixos/";

    # some NetworkManager configuration
    "NetworkManager/system-connections".source =
      "/nix/persist/etc/NetworkManager/system-connections/";

  };

}

