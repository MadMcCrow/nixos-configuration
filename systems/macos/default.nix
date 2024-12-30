# macos/default.nix
# all darwin machines
{
  addModules,
  addUsers,
  darwin,
  home-manager-darwin,
  mac-app-util,
  nixpkgs-darwin,
  self,
  ...
}:
let
  mkMacOS =
    module:
    darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        nixpkgs = nixpkgs-darwin;
      };
      modules =
        (addModules [ "macos" ])
        ++ (addUsers [ "perard" ])
        ++ [
          module
          mac-app-util.darwinModules.default
          home-manager-darwin.darwinModules.home-manager
          (_: {
            # To enable it for all users:
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
          })
        ];
    };
in
{
  # MacBook Air M1
  anacreon = mkMacOS ./MBA.nix;
}
