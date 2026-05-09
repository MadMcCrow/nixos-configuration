# Validation of the TOML configuration
{ lib, config, options, ... }:
with lib;
with builtins;
let
  optAttr = a: k: lib.attrByPath (lib.splitString "." k) null a;

  # Safety: Skip internal metadata that can point back to the root evaluation,
  # which is the primary cause of stack overflows in the module system.
  ignoredKeys = [
     "type" "default" "description" "example"
    "readOnly" "apply" "declarations" "files" "visible"
    "internal" "loc" "value" "valueMeta" "configuration"
    "options" "highestPrio" "definitions" "definitionsWithPrio"
    "displayDefault" "relatedPackages"
  ];

  collectOptions = attrs:
  let
    # check option
    go = path: a:
      concatMap
        (key:

          if elem key ignoredKeys then [] else
          let
            v = a.${key};
            currentPath = if path == "" then key else "${path}.${key}";
          in
            if isAttrs v
            then
              if (optAttr v "_type") == "option"
              then [ currentPath ]
              else go currentPath v
            else []
        )
        (attrNames a);
  in
    go "" attrs;

  optsKeys = collectOptions options.nonOS;

  # collect all mandatory options paths :
  mandatoryPaths = filter (k: (optAttr options.nonOS "${k}.type._mandatory") == true ) optsKeys;

  # collect all unknown keys :
  unknownKeys = filter (k: !(elem k optsKeys)) (attrNames config.nonOS);

in
{
  options.nonOS = lib.mkOption {
    type = lib.types.submodule {
      freeformType = lib.types.attrsOf lib.types.anything;
    };
    description = "NonOS configuration root (populated from TOML)";
  };

  config.warnings = map (key:
      "NonOS Warning: Unknown key '${key}' found in your TOML configuration. It will be ignored."
    ) unknownKeys;
}
