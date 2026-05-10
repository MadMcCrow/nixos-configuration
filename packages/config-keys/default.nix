# create the validation schema once
{
  writeText,
  lib,
  self,
  import-tree,
  ...
}@args:
with lib;
let
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
  optionPaths = collectPaths "nonOS" evaluated.options.nonOS;

in
writeText "config-keys.toml" ''
  # Auto-generated from NixOS modules — do not edit manually
  known_options = [
  ${concatMapStrings (p: "  \"${p}\",\n") optionPaths}]
''
