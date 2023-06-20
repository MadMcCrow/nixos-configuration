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
      # various users on the system
      # TODO : move this to a separate file (JSON ?) or separate folder
      flakeUsers = {
        perard = {
          name = "perard";
          uid = 1000;
          description = "Noé Perard-Gayot";
          extraGroups = [ "wheel" "flatpak" "steam" ];
          initialHashedPassword =
            "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
          extraOptions = {
            gitEmail = "noe.perard+git@gmail.com";
            gitUser = "MadMcCrow";
          };
        };
      };

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
              desktop.gnome.enable = true;
              desktop.gnome.superExtraApps = true;
              input.xone.enable = true;
              audio.pipewire.enable = true;
              userList = [ flakeUsers.perard ];
            }
          ];
        };

        # DreamCloud, my personal Local Server
        #DreamCloud = nixpkgs.lib.nixosSystem {
        #  system = "x86_64-linux";
        #  specialArgs = inputs;
        #  modules = [
        #    ./modules
        #    ./systems/DreamCloud/configuration.nix
        #    { nixos.enhancedSecurity.enable = true; }
        #  ];
        #};
      };

      # MacOS
      darwinSystems = rec {
        Noes-MacBook-Air = darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./modules/darwin
            ./systems/MBA/configuration.nix
            {
              darwin = {
                enable = true;
                apps = true;
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

