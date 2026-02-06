# macos/default.nix
# all darwin machines
{ darwin, nixpkgs, mac-app-util, home-manager, self, ... }:
let
  mkMacOS =
    {
      module,
      system ? "aarch64-darwin",
    }:
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit nixpkgs;
      };
      modules = [
        ../modules/macos
        # (self + /users)
        module
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager
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
  foundry = mkMacOS { module = ./MBA.nix; };
}
