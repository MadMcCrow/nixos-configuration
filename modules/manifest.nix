# manifest file : ignored by import tree
# but useful for building the module list
inputs@{
  lib,
  import-tree,
  disko,
  nonOS,
  ...
}:
let
  mkMod = dir: deps:
  let
    modules = (import-tree.leafs dir);
  in
   (map (x: lib.modules.importApply x nonOS) modules) ++ deps;
in
{
  core = mkMod ./core [ disko.nixosModules.disko ];
  desktop = mkMod ./desktop [];
}
