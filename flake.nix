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

    # use GTK4 for firefox
    firefox-gnome-theme = { url = "github:rafaelmardojai/firefox-gnome-theme"; flake = false; };

  };

  outputs = { self, nixpkgs, darwin, home-manager, agenix, ... }@inputs:
    let
      # shortcut function :
      nixOSx86 = sysModule :
      let 
        pkgs = nixpkgs;
        system = "x86_64-linux";
        sysArgs = import sysModule {inherit pkgs system;};
        specialArgs = inputs;
      in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
          agenix.nixosModules.default
          home-manager.nixosModule
          home-manager.nixosModules.home-manager
          ./modules
          ./users
          sysArgs
          ] ;
        };

      darwinAarch64 = system : 
      darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = inputs;
          modules = [
          home-manager.darwinModules.home-manager
          ./modules 
          ./users/darwin.nix
          system { darwin.enable = true; darwin.apps.enable = true;}];
      };

    in {

      #Linux : Nixos
      nixosConfigurations = {
        # AF, my personal Desktop PC
        nixAF = nixOSx86  ./systems/AF.nix;

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
    };
}

