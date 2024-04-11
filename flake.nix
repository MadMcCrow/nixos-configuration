# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";
  # flake inputs :
  inputs = {
    # Linux:
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # plasma-manager.url = "github:pjones/plasma-manager";
    # plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    # plasma-manager.inputs.home-manager.follows = "home-manager";

    # macOS:
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager-darwin.url = "github:nix-community/home-manager/release-23.11";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = { self, ... }@inputs:
    let
      # shortcut functions :
      nixOSx86 = sysModule:
        inputs.nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit (inputs) impermanence nixpkgs plasma-manager;
            pkgs-latest = import inputs.nixpkgs-latest { inherit system; };
          };
          modules = [
            ./linux
            ./users
            inputs.home-manager.nixosModule
            inputs.home-manager.nixosModules.home-manager
            sysModule
          ];
        };

      darwinAarch64 = sysModule:
        inputs.darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs = {
            inherit (inputs) impermanence nixpkgs;
            pkgs-latest = import inputs.nixpkgs-latest { inherit system; };
          };
          modules = [
            ./darwin
            ./users
            inputs.home-manager-darwin.darwinModules.home-manager
            sysModule
          ];
        };

    in {

      #Linux : Nixos
      nixosConfigurations = {
        nixAF = nixOSx86 ./systems/AF.nix;
        nixNUC = nixOSx86 ./systems/NUC.nix;
      };

      # MacOS
      darwinConfigurations = {
        Noes-MacBook-Air = darwinAarch64 ./systems/MBA.nix;
      };

      overlays = {
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages if system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs {
              system = "x86_64-darwin";
              inherit (inputs.nixpkgs) config;
            };
          };
      };

      # a shell for every development experiment
      devShells = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ] (system: {
        default = let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          paths = map (x: import x ({ inherit pkgs; } // inputs)) shells;
          # this is sad, for now I just merge build inputs but another solution would be great
          # another solution would be to merge all attributes but this would take too much time for nothing
          # pkgs.buildEnv { name = "nixos-configuration shell";  inherit paths; };
        in pkgs.mkShell {
          buildInputs = builtins.concatLists (map (x: x.buildInputs) paths);
        };
      });
    };
}
