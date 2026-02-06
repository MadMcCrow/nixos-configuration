# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";
  # flake inputs :
  inputs = {
    # Linux:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/refs/tags/25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # HM :
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ## Secure boot
    ## TODO : move to npin or something !
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # macOS:
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
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
      #packages =
      #  nixpkgs.lib.genAttrs
      #    [
      #      "x86_64-linux"
      #      "aarch64-darwin"
      #    ]
      #    (
      #      system:
      #      let
      #        pkgs = nixpkgs.legacyPackages.${system};
      #      in
      #      pkgs.callPackages ./packages { }
      #   );
    };
}
