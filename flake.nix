# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    # impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # macOS
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Agenix for secrets
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "darwin";

    # pycnix for python scripts
    pycnix.url = "github:MadMcCrow/pycnix";
    pycnix.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, darwin, home-manager, agenix, ... }@inputs:
    let

      # modules shared between linux and MacOS
      baseModules = s : p : [ ./modules ./users ./secrets (import s { pkgs = nixpkgs; system = p; }) {platform = p;}];

      # shortcut functions :
      nixOSx86 = m :
        let
          pkgs = nixpkgs;
          system = "x86_64-linux";
          specialArgs = inputs;
        in nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            agenix.nixosModules.default
            home-manager.nixosModule
            home-manager.nixosModules.home-manager
          ] ++ ( baseModules m system);
        };

      darwinAarch64 =  m :
        let
          system = "aarch64-darwin";
        in darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [ home-manager.darwinModules.home-manager ] ++ ( baseModules m system);
        };

        shells = [ ./secrets/shell.nix ];

    in {

      #Linux : Nixos
      nixosConfigurations = {
        # AF, my personal Desktop PC
        nixAF = nixOSx86 ./systems/AF.nix;

        # my NUC acting as a headless server
        nixNUC = nixOSx86 ./systems/NUC.nix;
      };

      # MacOS
      darwinConfigurations = {
        # my MacBook Air
        Noes-MacBook-Air = darwinAarch64 ./systems/MBA.nix;
      };

      overlays = {
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages if system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs {
              system = "x86_64-darwin";
              inherit (nixpkgs) config;
            };
          };
      };

      # a shell for every development experiment
      devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin"]  (
      system: 
      {
        default = let
          pkgs = nixpkgs.legacyPackages.${system};
          paths = map (x : import x ({inherit pkgs;} // inputs) ) shells;
        in
          pkgs.buildEnv { name = "nixos-configuration shell";  inherit paths; };
      }
      );
      
    };
}
