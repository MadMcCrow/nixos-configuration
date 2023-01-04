# nixos/nix.nix
#	settings for nixos and nix-store
{ pkgs, config, nixpkgs, lib, ... }:
with builtins;
with lib;
let cfg = config.nixos.nix;
in {
  #interface
  options.nixos.nix = {
    updateDates = mkOption {
      type = types.str;
      default = "04:40";
      example = "daily";
      description = lib.mdDoc ''
        How often upgrade, optimize and garbage collection occurs.
        The format is described in
        {manpage}`systemd.time(7)`.
      '';
    };
  };

  config = {
    # nix
    nix = {
      package =
        pkgs.nixVersions.unstable; # or versioned attributes like nixVersions.nix_2_8
      extraOptions = "experimental-features = nix-command flakes";
      # GarbageCollection
      gc = {
        automatic = true;
        dates = cfg.updateDates;
        persistent = true;
      };
      settings.auto-optimise-store = true;
      optimise.dates = [ cfg.updateDates ];

      # pin nixpkgs to the one installed on the system
      registry.nixpkgs.flake = nixpkgs;
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
      flags =
        [ "--update-input" "nixpkgs" "--commit-lock-file" ]; # update inputs
      dates = cfg.updateDates;
      allowReboot = false;
    };
  };
}
