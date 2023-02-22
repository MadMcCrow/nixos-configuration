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

  outputs = { self, nixpkgs, darwin, home-manager, ... }@inputs:
    let inherit (darwin.lib) darwinSystem;
    in {

      #Linux : Nixos
      nixosConfigurations = {

        # AF, my personal Desktop PC
        nixAF = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./modules
            ./systems/AF/configuration.nix
            {
              # desktop env
              desktop.gnome = {
                enable = true;
                extraApps = true;
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

        # DreamCloud, my personal Local Server
        DreamCloud = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./modules
            ./systems/DreamCloud/configuration.nix
            { nixos.enhancedSecurity.enable = true; }
          ];
        };
      };

      # MacOS
      darwinSystems = rec {
        # my MBA - that I need to rename
        Noes-MacBook-Air = darwinSystem {
          system = "aarch64-darwin";
          modules = self.darwinModules ++ [ ./systems/MBA/configuration.nix ];
        };
      };

      # Overlay for apple-silicon, does not apply to linux
      overlays = {
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs-unstable {
              system = "x86_64-darwin";
              inherit (nixpkgs) config;
            };
          };
      };
    };
}

