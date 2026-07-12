# nixpkgs.nix
# define how nonOS gets its nixpkgs
inputs @ {
  config,
  nonOS,
  lib,
  pkgs,
  ...
}:
with lib;
let
  os = nonOS __curPos inputs;
in
{
  options = os.options {
    # global option to allow unfree packages
    _unfreePackages = mkStrListOption "accepted unfree packages" [ ];
    dir = mkPathOption "configuration directory" "/etc/nonOS";
  };

  config = mkIf os.enabled {
    nix = {
      nixPath = [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "/nix/var/nix/profiles/per-user/root/channels"
        "nixpkgs=flake:nixpkgs"
      ];

      package = pkgs.lix;

      settings = {
        # keep flake and commands
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        # cache providers
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
          "https://cachix.cachix.org"
          "https://nixpkgs.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
          "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        ];

      };
    };


    nixpkgs = {
      # help other modules define allowed unfree packages
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config._unfreePackages;
      pkgs = import (import ${os.cfg.dir}/npins).nixpkgs {};
    };
}
