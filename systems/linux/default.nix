# linux/default.nix
# all linux systems
{
  addModules,
  addUsers,
  home-manager,
  lanzaboote,
  nixos-hardware,
  nixpkgs,
  self,
  ...
}:
let
  # helper function 
  mkX86Linux =
    mod:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit
          nixpkgs
          nixos-hardware
          addModules
          lanzaboote
          home-manager
          self;
      };
      modules = [ mod ] 
      # TODO : move user out of here and specify it in devices :
      ++ (addUsers [ "perard" ]);
    };
in
{
  # NUC
  terminus = mkX86Linux ./NUC.nix;
  # desktop PC
  trantor = mkX86Linux ./TAF.nix;
  # chromebook
  smyrno = mkX86Linux ./SCP.nix;
  # live iso for installation :
  # iso = mkX86Linux ./ISO.nix;
}
