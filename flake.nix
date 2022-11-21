{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # impermanence
    impermanence.url = "github:nix-community/impermanence";

    # gaming
    nix-gaming.url = "github:fufexan/nix-gaming";

    # hyprland DE
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs: {

    # desktop configuration
    nixosConfigurations.nixAF = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./modules/default.nix
        ./systems/AF/configuration.nix
        {
          # core
          core.enhancedSecurity.enable = false;

          # users
          users.guest.enable = true;

          # gnome
          gnome.enable = true;
          gnome.superExtraApps = true;

          apps.firefox.enable = true;
          apps.firefox.wayland = true;

          # other apps
          apps.flatpak.enable = true;
          apps.discord.enable = true;
          apps.pidgin.enable = false;
          apps.steam.enable = true;
          apps.gamemode.enable = true;
          apps.development.enable = true;

          # input
          input.xone.enable = true;
          input.remapper.enable = false;
        }
      ];
    };
  };
}

