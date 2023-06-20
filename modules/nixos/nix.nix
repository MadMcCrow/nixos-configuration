# nixos/nix.nix
#	settings for nixos and nix-store
{ pkgs, config, nixpkgs, lib, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.nix;
in {
  #interface
  options.nixos.nix = {
    # overriden for most configs
    enable = mkEnableOption (mdDoc "nix system for nixos") // {
      default = true;
    };
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
    autoReboot = mkEnableOption (mdDoc "reboot post upgrade");
  };

  config = mkIf cfg.enable {
    # nix
    nix = {
      # or versioned attributes like nixVersions.nix_2_8
      package = pkgs.nixVersions.unstable;
      # add flake support
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

      # add support for cachix
      settings = {
        substituters = [
          "https://nixos-configuration.cachix.org"
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
        ];
        trusted-public-keys = [
          "nixos-configuration.cachix.org-1:dmaMl2SX7/VRV1qAQRntZaNEkRyMcuqjb7H+B/2jlF0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    # absolutely required packages
    environment.systemPackages = with pkgs; [ git git-crypt cachix vulnix ];

    # automatic updates :
    # this flake is updated by Github actions and thus do not require manual updates
    system = {
      autoUpgrade = {
        enable = true; # enable auto upgrades
        persistent = true; # apply if missed
        flake = "github:MadMcCrow/nixos-configuration"; # this flake
        dates = cfg.updateDates;
        allowReboot = cfg.autoReboot;
      };
      # this would need to have some script running before update :
      # one way to do so would be to wrap nixos-rebuild. not sure about purity though.
      #nixos.label = "$today.$branch-${revision:0:7}" + (concatStringsSep "-" ((sort (x: y: x < y) config.system.nixos.tags)));
    };
  };
}
