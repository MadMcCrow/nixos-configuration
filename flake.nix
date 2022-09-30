{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # impermanence
    impermanence.url = "github:nix-community/impermanence";

    # gaming
    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  outputs = { self, nixpkgs, home-manager, impermanence, nix-gaming }@inputs: {

    # desktop configuration
    nixosConfigurations.nixAF = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./modules/default.nix
        ./systems/AF/configuration.nix
        {
          apps.flatpak.enable = true;
          apps.multimedia.enable = false;
          apps.vscode.enable = true;
          users.guest.enable = false;
          apps.discord.enable = true;
        }
      ];
    };
  };
}

