# mkConfig.nix
# Arguments for mkSystem.nix and mkAppliance.nix
# This allows to pass common arguments to both functions.
{ self, lib, import-tree, ... } @ args:
# create the attribute set for "nixpkgs.lib.nixosSystem"
tomlPath:
let
  # read the TOML config file
  tomlConfig = builtins.fromTOML (builtins.readFile tomlPath);
  # append options to the specialArgs set
  specialArgs = let
    nonlib = import ./options.nix (args // { inherit tomlPath; });
  in args // {
    inherit nonlib;
    inherit (nonlib) nonOS;
  };
in {
  # we default to "x86_64-linux" if not specified in the TOML config
  system = tomlConfig.system or "x86_64-linux";
  inherit specialArgs;
  modules = [
    (import-tree (self + "/modules"))
    ./validation.nix
    {
      # do all the custom parsing there :
      nonOS = tomlConfig;
    }
  ];
}
