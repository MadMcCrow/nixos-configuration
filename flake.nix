# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # Nixpkgs
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # impermanence
    impermanence.url = "github:nix-community/impermanence";

    # gaming
    nix-gaming.url = "github:fufexan/nix-gaming";

    # macOS
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs for MacOS
    nixpkgs-darwin = { url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin"; };

    # hyprland DE
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }@inputs: {

    # desktop configuration
    nixosConfigurations.nixAF = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./modules
        ./systems/AF/configuration.nix
        {
          # desktop env
          desktop.gnome = {
            enable = true;
            superExtraApps = true;
          };
          # apps
          apps = {
            enable = true;
            graphics.enable = true;
            development.enable = true;
            games.enable = true;
            web.enable = true;
            multimedia.enable = true;
          };
          # input
          input.xone.enable = true;
          # audio
          audio.pipewire.enable = true;
        }
      ];
    };

    darwinSystems.Noes-MacBook-Air = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./systems/MBA/configuration.nix
        ./modules
        {
          audio.enable = false;
          nixos.enable = false;
          input.enable = false;
          desktop.enable = false;
        }
      ];
    };
  };

}

