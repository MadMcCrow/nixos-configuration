# Here we configure some basic nixos features
{ pkgs, config, lib, ... }: {
  # Nix
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # GarbageCollection
    gc = {
      automatic = true;
      dates = "daily";
    };
    settings.auto-optimise-store = true;
    optimise.dates = " daily";
  };
}
