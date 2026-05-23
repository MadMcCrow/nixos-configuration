# create the validation schema once
{
  writeTextFile,
  lib,
  self,
  import-tree,
  ...
}@args:
with lib;
let
  # array name
  topName = "validKeys";
  # how to prefix keys
  prefix = "";
  # name = with builtins; baseNameOf (dirOf __curPos.file);
  name = "config-keys";

  evaluated = lib.evalModules {
    modules = [
      (import-tree (self + "/modules"))
      { _module.check = false; }
    ];
    specialArgs = args // {
      inherit pkgs lib;
      nonlib = import (self + "/lib") args;
    };
  };

  # Keys that indicate we've hit a mkOption leaf — stop recursing
  invalidKeys = [
    "_type"
    "type"
    "default"
    "description"
    "example"
    "visible"
    "internal"
    "readOnly"
    "declarations"
    "definitionsWithLocations"
  ];

  collectPaths =
    prefix: tree:
    concatLists (
      mapAttrsToList (
        name: val:
        let
          path = if prefix == "" then name else "${prefix}.${name}";
        in
        if hasPrefix "_" name then
          [ ] # skip _module, _type etc.
        else if isOption val then
          [ path ] # proper isOption check
        else if isAttrs val && any (k: val ? ${k}) invalidKeys then
          [ path ] # looks like a mkOption, stop here
        else if isAttrs val then
          collectPaths path val # safe to recurse
        else
          [ ]
      ) tree
    );

  # Only walk options under the `os` key — avoids all NixOS internals
  optionPaths = collectPaths prefix evaluated.options.nonOS;

in
writeTextFile {
  inherit name;
  destination = "/${name}.toml";  # path inside the derivation
  text = ''
    # Auto-generated from NixOS modules — do not edit manually
    # instead, call `nix build .#${name}`
    ${topName} = [
    ${lib.concatStringsSep ",\n" (map (p: "  \"${p}\"") optionPaths)}
    ]
  '';
}
