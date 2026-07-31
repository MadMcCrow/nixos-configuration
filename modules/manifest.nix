# manifest file : ignored by import tree
# but useful for building the module list
inputs@{
  lib,
  import-tree,
  disko,
  lanzaboote,
  nonOS,
  ...
}:
let
  mkMod =
    dir: deps:
    let
      modules = import-tree.leafs dir;
    in
    (map (x: lib.modules.importApply x nonOS) modules) ++ deps;
in
{
  #  disks, format, boot, networking, updates
  core = mkMod ./core [
    disko.nixosModules.disko
    lanzaboote.nixosModules.lanzaboote
  ];
  # desktop environment
  desktop = mkMod ./desktop [ ];
}
