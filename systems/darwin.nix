# darwin.nix
# Function to have nix installation on MacOS 
#
{
  nixpkgs-darwin,
  darwin,
  mac-app-util,
  home-manager-darwin,
  ...
}:
{
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
        ../platform/darwin
        ../users
        module
        mac-app-util.darwinModules.default
        home-manager-darwin.darwinModules.home-manager
        (
          { ... }:
          {
            # To enable it for all users:
            home-manager.sharedModules = [ mac-app-util.homeManagerModules.default ];
          }
        )
      ];
    };
}
