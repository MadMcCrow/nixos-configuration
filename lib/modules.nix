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
  specialArgs = import ./specialArgs inputs;

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
      // (listToAttrs (x: {
        name = x;
        value = self: self.filter (lib.hasInfix "/${name}/");
      }) modulesNames)
    )
  );

  modules = listToAttrs (
    map (x: {
      name = x;
      value = _: {
        imports = [ modules-tree.${x} ];
        config._module.args = specialArgs;
      };
    }) (modulesNames ++ [ "all" ])
  );
in
modules
// {
  default = modules.core;
}
