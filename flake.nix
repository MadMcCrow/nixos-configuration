# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # Nixpkgs
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };

    # old version for apps that fails to work properly on unstable
    # nixpkgs-stable = { url = "github:nixos/nixpkgs/nixos-22.11"; };
    # then use : stable-pkgs = inputs.nixpkgs-stable.legacyPackages.${pkgs.system}

    # Home manager
    home-manager = {
      # use /release-22.11 for stable
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # impermanence
    impermanence.url = "github:nix-community/impermanence";

    # macOS
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs for MacOS
    nixpkgs-darwin = { url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin"; };

  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;

      nixOSx86 = args:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules =
            [ ./modules ./users/nixos.nix ./systems/AF/configuration.nix args ];
        };

    in {

      #Linux : Nixos
      nixosConfigurations = {

        # AF, my personal Desktop PC
        nixAF = nixOSx86 {
          # desktop env
          desktop.gnome.enable = true;
          desktop.gnome.superExtraApps = true;
          nixos.flatpak.enable = true;
          input.xone.enable = true;
          audio.pipewire.enable = true;
        };
        # my NUC acting as a headless server
        NUC-Cloud = nixOSx86 { 
          server.enable = true;
        };
      };

      # MacOS
      darwinSystems = {
        Noes-MacBook-Air = darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./modules/darwin
            ./users/darwin.nix
            ./systems/MBA/configuration.nix
            home-manager.darwinModules.home-manager
            {
              darwin = {
                enable = true;
              };
            }
          ];
        };
      };

      # Overlay for apple-silicon, does not apply to linux
      overlays = {
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs {
              system = "x86_64-darwin";
              inherit (nixpkgs) config;
            };
          };
      };
    };
}

