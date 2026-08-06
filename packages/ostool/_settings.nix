# ostool/_config.nix
# build a derivation containing all that's necessary for the tool
inputs@{
  self,
  lib,
  callPackage,
  symlinkJoin,
  writeTextFile,
  ...
}:
with builtins;
let
  # env flags for passing to python
  # TODO : replace by Json generated file
  settings = {
    pins = {
      nixpkgs =
        let
          pin = (fromJSON (readFile (self + "/flake.lock"))).nodes.nixpkgs;
        in
        {
          platform = "github";
          owner = "nixOS";
          repo = "nixpkgs";
          rev = pin.locked.rev;
          branch = baseNameOf (dirOf pin.original.url);
        };
      nonOS = {
        platform = "github";
        owner = "MadMcCrow";
        repo = "nonOS";
        rev = "";
        branch = "";
      };
    };
    template = import ./_template.nix inputs;
  };
in
(writeTextFile {
  name = "ostools-settings";
  text = (toJSON settings);
  destination = "/settings.json";
})