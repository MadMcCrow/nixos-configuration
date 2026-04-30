# update.nix
# define the update process in NonOS
{ config, pkgs, lib, self, ... }: {

  # this is a private option : you cannot access it from the TOML config
  options._nonOS.unfreePackages = with lib; mkOption {
    type = with types; listOf str;
    default = [];
    description = "List of unfree packages to allow in NonOS";
  };

  config = {

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config._nonOS.unfreePackages;

    nix = {
      nixPath = [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "/nix/var/nix/profiles/per-user/root/channels"
        "nixpkgs=flake:nixpkgs"
      ];

      package = pkgs.lix;

      settings = {
        # keep flake and commands
        experimental-features = [ "nix-command" "flakes" ];

        # cache providers
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
          "https://nixos-configuration.cachix.org"
          "https://cachix.cachix.org"
          "https://nixpkgs.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nixos-configuration.cachix.org-1:dmaMl2SX7/VRV1qAQRntZaNEkRyMcuqjb7H+B/2jlF0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
          "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        ];

      };
    };
    environment.systemPackages = [
      self.packages.${pkgs.system}.os-update # our updater
    ];

    system.stateVersion = "25.11";
  };
}
