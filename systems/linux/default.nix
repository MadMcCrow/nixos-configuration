# linux/default.nix
# all linux systems
{
  addModules,
  addUsers,
  nixpkgs,
  nixpkgs-unstable,
  nixos-hardware,
  lanzaboote,
  home-manager,
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
          nixpkgs-unstable
          nixos-hardware
          addModules
          lanzaboote
          home-manager
          ;
      };
      modules = [
        mod
        ] ++ addUsers ["perard"];
    };
in
{
  # NUC
  terminus = mkX86Linux ./NUC.nix;
  # desktop PC
  # trantor = mkX86Linux ./TAF.nix;
  # chromebook
  # smyrno = mkX86Linux ./SCP.nix;
  # live iso for installation :
  # iso = mkX86Linux ./ISO.nix;
}
