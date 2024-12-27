# macos/default.nix
# all darwin machines
{ mac-app-util, home-manager-darwin }:
let
  mkMacOS =
    {
      module,
      nixpkgs ? nixpkgs-darwin,
      system ? "aarch64-darwin",
    }:
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit nixpkgs;
      };
      modules = [
        ../modules/darwin
        (self + /users)
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
  anacreon = mkMacOS ./MBA;
}
