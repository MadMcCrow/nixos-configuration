# core/nixos.nix
#	setting nixos and nix-store
{ pkgs, config, ... }:
with builtins;
with lib; {
  # nix
  nix = {
    package =
      pkgs.nixVersions.unstable; # or versioned attributes like nixVersions.nix_2_8
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
  environment.systemPackages = with pkgs; [ git git-crypt cachix vulnix ];

  # root git config
  programs.git.config = {
    user = {
      email = "root@nix.com"; # fake email, allows to commit locally
      name = "root"; # name
    };
  };

  # automatic updates :
  system.autoUpgrade = {
    enable = true; # enable auto upgrades
    persistent = true; # apply if missed
    flake = "github:MadMcCrow/nixos-configuration"; # this flake
    flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ]; # update inputs
    dates = "daily";
    allowReboot = false;
  };

}
