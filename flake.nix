# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
    {
      # all of our systems
      inherit (import ./systems inputs) 
        nixosConfigurations # linux machines
        darwinConfigurations; # macOS machines

      packages = import ./packages inputs;
    };
}
