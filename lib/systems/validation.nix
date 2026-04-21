{ lib, config, options, ... }:
with lib;
let
  # Helper: Identifies if a value is a NixOS option definition
  isOption = v: v ? _type && v._type == "option";

  # Helper: Identifies if an option was created using mkMandatoryOption
  isMandatory = v: v ? type && v.type ? _mandatory && v.type._mandatory;

  # Recursively crawls the options tree to find mandatory paths.
  # We strictly avoid metadata attributes to prevent stack overflows and evaluation loops.
  findMandatory = prefix: opts:
    let
      # Base case: this node is an option, check if it's mandatory
      current = if isOption opts && isMandatory opts then [ prefix ] else [ ];

      # Recursive case: if this node is an attribute set, look at its children.
      # We skip internal NixOS metadata like _type, type, default, loc, etc.
      names = if isAttrs opts then builtins.attrNames opts else [ ];
      validNames = filter (n:
        !(hasPrefix "_" n) && !(elem n [
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
          "valueMeta"
          "configuration"
          "options"
        ])) names;
      childrenPaths = concatLists
        (map (name: findMandatory (prefix ++ [ name ]) opts.${name})
          validNames);
    in current ++ childrenPaths;

  mandatoryOptions = findMandatory [ ] options.nonOS;

  # Check if a path exists and is not null in the configuration
  isSet = path: (attrByPath path null config.nonOS) != null;

  # To identify unknown keys, we check if they exist in the options tree.
  # We look for attributes that are NOT part of the standard mkOption metadata.
  isOptionKey = n:
    !(elem n [
      "_type"
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
    ]);

  definedOptions = filter isOptionKey (attrNames options.nonOS);
  providedConfig = attrNames config.nonOS;
  unknownKeys = filter (key: !(elem key definedOptions)) providedConfig;
in {
  config = {
    assertions = map (path: {
      assertion = isSet path;
      message = "NonOS Error: Mandatory option 'nonOS.${
          concatStringsSep "." path
        }' is missing in your TOML config.";
    }) mandatoryOptions;

    warnings = map (key:
      "NonOS Warning: Unknown key '${key}' found in your TOML configuration. It will be ignored.")
      unknownKeys;
  };
}
