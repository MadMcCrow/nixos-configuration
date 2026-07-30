# configurations.nix
# use import-tree to import all our "fake" hosts
inputs@{
  self,
  lib,
  import-tree,
  ...
}:
with builtins;
with lib;
let
  # build a standard nixOS hosts from a configuration
  mksysPair = mod: rec{
    name = unsafeDiscardStringContext (baseNameOf (dirOf (mod)));
    value = nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        nonOS = self.outputs;
      };
      modules = [ mod ];
    };
  };

  # find all configurations
  configurations = import-tree
  (i: i.leafs)
  (i: i.filter (match "configuration.nix"))
  (i: i (self + "/hosts";));

in
# build attrset
listToAttrs (map mksysPair configurations)