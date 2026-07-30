# modules.nix
# exposes all of our modules
inputs@{
  self,
  lib,
  import-tree,
  ...
}:
with lib;
with builtins;
let
  version = import ./version.nix inputs;

  modulesNames = [
    "core"
    "desktop"
  ];

  modules-tree = import-tree (i: i.addPath (self + "/modules")) (
    i:
    i.addAPI (
      {
        all = self: self;
      }
      // (listToAttrs (
        map (x: {
          name = x;
          value = i: i.filter (lib.hasInfix "/${x}/");
        }) modulesNames
      ))
    )
  );

  modules = listToAttrs (
    map (x: {
      name = x;
      value = _: {
        imports = [ modules-tree.${x} ];
        config._module.args = {
          # expose our tool
          mod = import ./mkmod.nix inputs;
          # expose our inputs
          inherit (inputs) disko lanzaboote nixos-hardware;
        };
      };
    }) (modulesNames ++ [ "all" ])
  );
in
modules
// {
  default = modules.core;
}
