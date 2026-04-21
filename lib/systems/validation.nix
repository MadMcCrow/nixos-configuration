{ lib, config, options, ... }:
with lib;
let
  isOption = v: v ? _type && v._type == "option";
  isMandatory = v: v ? type && v.type ? _mandatory && v.type._mandatory;

  # Recursively crawls the options tree starting from 'prefix' to find mandatory paths.
  # Returns a list of attribute paths, e.g., [ ["hostname"] ["hardware" "storage" "main"] ]
  findMandatory = prefix: opts:
    let
      # processAttr is called for every attribute at the current level of the tree
      processAttr = name: value:
        let
          currentPath = prefix ++ [ name ];
        in
        if isOption value then
          # Base case: we found an option, return its path if it's mandatory
          if isMandatory value then [ currentPath ] else [ ]
        else if isAttrs value then
          # Recursive case: this is a category (attrset), keep digging
          findMandatory currentPath value
        else
          # Fallback for unexpected types
          [ ];

      # We filter out "_type" to avoid processing the metadata of the parent attrset
      cleanOpts = filterAttrs (n: v: n != "_type") opts;
    in
    concatLists (mapAttrsToList processAttr cleanOpts);

  mandatoryOptions = findMandatory [ ] options.nonOS;

  # Check if a path exists and is not null in the configuration
  isSet = path: (attrByPath path null config.nonOS) != null;

  missingMandatory = filter (path: ! (isSet path)) mandatoryOptions;

  # Top-level unknown keys logic (simplified for prototype)
  definedOptions = attrNames options.nonOS;
  providedConfig = attrNames config.nonOS;
  unknownKeys = filter (key: ! (elem key definedOptions)) providedConfig;
in
{
  options.nonOS = mkOption {
    type = types.submodule {
      freeformType = types.attrsOf types.anything;
    };
    description = "NonOS configuration root";
  };

  config = {
    assertions = map (path: {
      assertion = isSet path;
      message = "NonOS Error: Mandatory option 'nonOS.${concatStringsSep "." path}' is missing in your TOML config.";
    }) mandatoryOptions;

    warnings = map (key:
      "NonOS Warning: Unknown key '${key}' found in your TOML configuration. It will be ignored."
    ) unknownKeys;
  };
}
