# core/nixos.nix
#	setting nixos and nix-store
{ pkgs, config, ... }: {

  # nix
  nix = {
    package = nixVersions.unstable; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = "experimental-features = nix-command flakes";
    # GarbageCollection
    gc = {
      automatic = true;
      dates = "daily";
    };
    settings.auto-optimise-store = true;
    optimise.dates = " daily";
  };

  # persist:
  environment.etc = {

    # Nixos configuration files (ie. this)
    "nixos".source = "/nix/persist/etc/nixos/";

    # this yields a warning and might not be necessary anymore
    # some NetworkManager configuration
    #"NetworkManager/system-connections".source =
    #  "/nix/persist/etc/NetworkManager/system-connections/";
  };

  # absolutely required packages
  environment.systemPackages = with pkgs; [ git git-crypt cachix ];
}
