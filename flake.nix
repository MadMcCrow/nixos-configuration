# flake.nix
{
  description = "NonOS is an opinionated OS based on NixOS";

  inputs = {
    # nixpkgs
    # mandatory base package set
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Linux modules
    # additional hardware-specific modules for linux
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Python tools
    # build tools for OS commands
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

  outputs = { nixpkgs, ... }@inputs:
      let
            forAllSystems = nixpkgs.lib.genAttrs lib.systems.flakeExposed;
            lib = nixpkgs.lib // import ./lib;
      in {
           # there's only one configuration : the one that will be gathered at runtime
           nixosConfigurations.default = lib.mkSystem /etc/nixos/config.toml;
           # we use apps instead of packages because we want to be able to use `nix run`
           apps = forAllSystems (system: import ./packages.nix (inputs // { inherit system lib; }));
         };
    };
}
