# Validation of the TOML configuration
{ lib, config, options, ... }:
with lib;
with builtins;
let
  OSKey = "nonOS";

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
      builtins.concatMap
        (key:

          if elem key ignoredKeys then [] else
          let
            v = a.${key};
            currentPath = if path == "" then key else "${path}.${key}";
          in
            if builtins.isAttrs v
            then
              if (optAttr v "_type") == "option"
              then [ currentPath ]
              else go currentPath v
            else []
        )
        (builtins.attrNames a);
  in
    go "" attrs;

  optsKeys = collectOptions options.${OSKey};

  # collect all mandatory options paths :
  mandatoryPaths = filter (k: (optAttr options.${OSKey} "${k}.type._mandatory") == true ) optsKeys;

  # collect all unknown keys :
  # unknownKeys = filter (k: !(elem k optsKeys)) (builtins.attrNames config.${OSKey});

in
{
    # ASSERTIONS: Fail the build if mandatory fields are missing.
    assertions = map (path: {
      assertion = (optAttr config.${OSKey} path) != null;
      message = "NonOS Error: The mandatory configuration field '${path}' is missing in your TOML file.";
    }) mandatoryPaths;

    #WARNINGS: unrecognized keys
    #warnings = map (key:
    #  "NonOS Warning: Unknown key '${key}' found in your TOML configuration. It will be ignored."
    #) unknownKeys;
}
