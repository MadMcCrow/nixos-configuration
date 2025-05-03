# macos/default.nix
# all darwin machines
{
  addModules,
  addUsers,
  darwin,
  nixpkgs-darwin,
  ...
}@args:
let
  mkMacOS = module: rec {
    name = value.config.networking.hostName;
    value = darwin.lib.darwinSystem rec {
      system = "aarch64-darwin";
      pkgs = import nixpkgs-darwin { inherit system; };
      specialArgs = args // {
        nixpkgs = nixpkgs-darwin;
      };
      modules =
        (addModules [
          "macos"
          "home/macos"
        ])
        ++ (addUsers [ "perard" ])
        ++ [ module ];
    };
  };
in
builtins.listToAttrs (map mkMacOS [ ./MBA.nix ])
