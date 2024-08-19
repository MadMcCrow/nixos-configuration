# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";
  # flake inputs :
  inputs = {
    # Linux:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/refs/tags/24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # HM :
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    ## Secure boot
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.1";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    ## Plasma
    # TODO : nix run github:pjones/plasma-manager
    # plasma-manager.url = "github:pjones/plasma-manager";
    # plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    # plasma-manager.inputs.home-manager.follows = "home-manager";

    # macOS:
    # TODO : remove what's not useful
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager-darwin.url = "github:nix-community/home-manager/release-24.05";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { nixpkgs, ... }@inputs:
    let systems = import ./systems inputs;
    in {
      # all of our systems
      inherit (systems) nixosConfigurations darwinConfigurations;

      # support packages :
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ]
        (system:
          let pkgs = nixpkgs.legacyPackages.${system};
          in pkgs.callPackages ./packages { });
    };
}
