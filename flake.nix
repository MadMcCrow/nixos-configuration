{
  description = "NonOS is an opinionated OS based on NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      self,
      import-tree,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        flake = let
          args = inputs // {inherit lib;};
        in{
          lib = {
          #   mkSystem =  : with (import ./lib/systems.nix args); (mkNixosSystem toml);
          };
          nixosModules.default = (import ./lib/modules.nix  args).default;
        };

        perSystem =
          args @{
            config,
            system,
            pkgs,
            lib,
            ...
          }:
          with pkgs;
          {
            # For standardised reproducible formatting with `nix fmt`
            formatter = nixfmt-tree;

            # import everything in the `packages` folder, based on its path
            packages = import ./lib/packages.nix (inputs // args);

            devShells.default = import ./shell.nix { inherit pkgs; };

            # checks = import ./tests (inputs //{ inherit pkgs lib;});
          };
      }
    );
}
