{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Utilities for building our flake
    #flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, impermanence} @inputs: {

    # desktop configuration
    nixosConfigurations.nixAF = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./modules/default.nix
        ./systems/AF/configuration.nix
        {
          sys.audio.server = "pulse";
          # sys.shell.zsh.enable = true; # todo
        }
      ];
    };
  };
}

