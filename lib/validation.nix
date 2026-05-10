# Validation of the TOML configuration
{
  lib,
  config,
  options,
  system,
  import-tree,
  self,
  ...
}@args:
with lib;
with builtins;
let
  optAttr = a: k: lib.attrByPath (lib.splitString "." k) null a;

  optsKeys =
    let
      evaluated = lib.evalModules {
        modules = [
          (import-tree (self + "/modules"))
          { _module.args = args; }
        ];
      };

      # Safety: Skip internal metadata that can point back to the root evaluation,
      # which is the primary cause of stack overflows in the module system.
      ignoredKeys = [
        "type"
        "default"
        "description"
        "example"
        "readOnly"
        "apply"
        "declarations"
        "files"
        "visible"
        "internal"
        "loc"
        "value"
        "valueMeta"
        "configuration"
        "options"
        "highestPrio"
        "definitions"
        "definitionsWithPrio"
        "displayDefault"
        "relatedPackages"
      ];

      # Recursively walk the evaluated option tree.
      # Each leaf where `_type == "option"` is a declared option;
      # everything else is a sub-tree (attribute set of more options).
      flattenOptions =
        prefix: tree:
        lib.foldlAttrs (
          acc: name: value:
          let
            path = if prefix == "" then name else "${prefix}.${name}";
            # Track visited paths to prevent infinite recursion
            visited = acc.visited or { };
            newVisited = visited // {
              ${path} = true;
            };
          in
          # Skip ignored keys to protect against infinite recursion
          if elem name ignoredKeys then
            acc
          # Prevent circular references by checking if we've already processed this path
          else if visited ? ${path} then
            acc
          # A real option node produced by lib.evalModules
          else if value ? _type && value._type == "option" then
            (acc // { ${path} = value; }) // { visited = newVisited; }
          # A sub-tree — recurse
          else if lib.isAttrs value then
            (acc // flattenOptions path (value // { visited = newVisited; })) // { visited = newVisited; }
          else
            (acc // { ${path} = value; }) // { visited = newVisited; }
        ) { visited = { }; } tree;
    in
    flattenOptions "" evaluated.options;

  # collect all mandatory options paths :
  mandatoryPaths = filter (k: (optAttr options.nonOS "${k}.type._mandatory") == true) optsKeys;

  # collect all known top-level keys from options
  tempTopLevelKeys = map (k: builtins.head (lib.splitString "." k)) optsKeys;
  knownTopLevelKeys = remove (x: x == null) tempTopLevelKeys;

  # collect all unknown keys - only check top-level keys
  unknownKeys = filter (k: !(elem k knownTopLevelKeys)) (attrNames config.nonOS);

in
{

  # add a warning for evey unknown key
  config.warnings = map (
    key: "NonOS Warning: Unknown key '${key}' found in your TOML configuration. It will be ignored."
  ) unknownKeys;
}
