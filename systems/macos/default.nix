# macos/default.nix
# all darwin machines
{
  addModules,
  addUsers,
  darwin,
  nixpkgs-darwin,
  ...
} @args :
let
  mkMacOS =
    module:
    darwin.lib.darwinSystem rec {
      name  = value.config.networking.hostName;
      system = "aarch64-darwin";
      pkgs = import nixpkgs-darwin {inherit system;};
      specialArgs = args // {nixpkgs = nixpkgs-darwin;};
      modules = 
      (addModules [ "macos" "home/macos"]) ++
      (addUsers [ "perard" ]) ++
      [ module ];
    };
in
{
  # MacBook Air M1
  anacreon = mkMacOS ./MBA.nix;
}
