# mkConfig.nix
# Arguments for mkSystem.nix and mkAppliance.nix
# This allows to pass common arguments to both functions.
{ self, lib, import-tree, nixpkgs, ... } @ args:
# create the attribute set for "nixpkgs.lib.nixosSystem"
tomlPath:
let
  # read the TOML config file
  tomlConfig = builtins.fromTOML (builtins.readFile tomlPath);
  system = tomlConfig.system or "x86_64-linux";

  # append options, packages and custom lib to the specialArgs set
  specialArgs = let
    nonlib = import ./options.nix (args // { inherit tomlPath; });
    pkgs = import nixpkgs {inherit system;};
  in nonlib // args // {
    inherit nonlib;
    inherit (nonlib) nonOS;
    nonPkgs = import (self + "/packages") (pkgs // args // {
      inherit system lib;
    });
  };

in {
  inherit system specialArgs;
  modules = [
    (import-tree (self + "/modules"))
    ./validation.nix
    {
      # do all the custom parsing there :
      nonOS = tomlConfig;
    }
  ];
}
