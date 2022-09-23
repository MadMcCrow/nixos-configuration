{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Utilities for building our flake
    #flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager }@inputs: {

    # the modules shared by all my systems
    nixosModules = import ./modules;

    # desktop configuration
    nixosConfigurations.nixAF = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixosModules
        ./systems/configuration-AF.nix
        {
          sys.audio.server = "pulse";
          # sys.shell.zsh.enable = true; # todo
        }
      ];
    };
  };
}

