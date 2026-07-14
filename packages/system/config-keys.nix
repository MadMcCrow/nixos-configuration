# create the validation schema once
{
  writeTextFile,
  lib,
  self,
  import-tree,
  prefix ? "",
  name ? "config-keys",
  ...
}@args:
with lib;
let

  destination = "/${name}.json";

  # eval empty config
  evaluated = lib.evalModules (
    (import (self + "/lib/system.nix") args).sysArgs { _module.check = false; }
  );

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
  # you can replace the '""' by a 'NonOS' for parser to have the full name
  optionPaths = collectPaths "" evaluated.options.nonOS;
  # filter for mandatory options
  mandatoryPaths = filter (
    p:
    lib.attrByPath (
      (splitString "." p)
      ++ [
        "type"
        "_mandatory"
      ]
    ) false evaluated.options.nonOS
  ) optionPaths;

in
(writeTextFile {
  inherit name;
  inherit destination; # path inside the derivation
  text = builtins.toJSON {
    "validKeys" = optionPaths;
    "mandatoryKeys" = mandatoryPaths;
  };
})
// {
  inherit destination;
}
