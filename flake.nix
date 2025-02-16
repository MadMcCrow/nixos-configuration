# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    # HM :
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Linux:
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    ## Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ## Plasma
    # TODO : nix run github:pjones/plasma-manager
    # plasma-manager = {
    # url = "github:pjones/plasma-manager";
    # inputs.nixpkgs.follows = "nixpkgs";
    # home-manager.follows = "home-manager";
    # };

    # macOS:
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      systems = import ./systems inputs;
    in
    {
      # all of our systems
      inherit (systems) nixosConfigurations darwinConfigurations;

      # support packages :
      packages =
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-darwin"
          ]
          (
            system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            pkgs.callPackage ./packages inputs
          );
    };
}
