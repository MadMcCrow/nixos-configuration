# system.nix
# define the update process in NonOS
{
  config,
  nonlib,
  lib,
  pkgs,
  nonpkgs,
  ...
}:
with nonlib;
let
flake_url = "https://github.com/MadMcCrow/nonOS";
# TODO :
# add cachix
in
nonOS __curPos config {
  globals.unfreePackages = mkStrListOption "accepted unfree packages" [ ];
  nonConfig =
    { cfg, globals, ... }:
    {

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) globals.unfreePackages;
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

      environment = {
        etc."os-release".text = ''
        NAME="nonOS"
        PRETTY_NAME="nonOS"
        ID=nixos
        BUILD_ID="rolling"
        ANSI_COLOR="1;32"
        HOME_URL="${flake_url}"
        SUPPORT_URL="${flake_url}"
        BUG_REPORT_URL="${flake_url}/issues"
      '';
        systemPackages = [nonpkgs.os  ];
      };


      system = {
        stateVersion = "26.05";
        nixos.label = "nonOS";
      };
    };
}
