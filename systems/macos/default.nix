# macos/default.nix
# all darwin machines
{
  addModules,
  addUsers,
  darwin,
  self,
  ...
} @args :
let
  mkMacOS =
    module:
    darwin.lib.darwinSystem rec {
      system = "aarch64-darwin";
      specialArgs = args;
      modules = 
      (addModules [ "macos" ]) ++
      (addUsers [ "perard" ]) ++
      [ module ];
    };
in
{
  # MacBook Air M1
  anacreon = mkMacOS ./MBA.nix;
}
