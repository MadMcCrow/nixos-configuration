# modules.nix
# use import-tree magic to make our custom TOML parser
{
  self,
  lib,
  import-tree,
  nixpkgs,
  ...
} @args :
tomlPath:
let
tomlConfig = builtins.readfile (builtins.fromToml tomlPath);
mkModules = import ./modules.nix;
in
nixpkgs.lib.nixosSystem {
system = tomlConfig.system or "x86_64-linux";
modules = [
  (mkModules self + "/modules")

  {
 config.nonOS = tomlConfig;
 }
];
});
