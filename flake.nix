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

    # desktop configuration
    nixosConfigurations.nixAF = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./modules
        ./systems/configuration-AF.nix
        {
          sys.audio.server = "pulse";
          # sys.shell.zsh.enable = true; # todo
        }
      ];
    };
  };
}

