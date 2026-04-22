{ lib, config, options, ... }:
with lib;
let
  # 1. SHARED METADATA DEFINITION
  # These are internal attributes that NixOS attaches to every option definition.
  # We must exclude these to distinguish between internal NixOS machinery
  # and the actual configuration keys defined in NonOS modules.
  internalMetadata = [
    "_type" "type" "default" "description" "example"
    "readOnly" "apply" "declarations" "files" "visible"
    "internal" "loc" "value" "valueMeta" "configuration"
    "options" "highestPrio" "definitions" "definitionsWithPrio"
    "displayDefault" "relatedPackages"
  ];

  # Helper: Returns true if an attribute name is internal metadata or private (starts with _).
  isInternal = name: (hasPrefix "_" name) || (elem name internalMetadata);

  # 2. RECURSIVE MANDATORY OPTION CRAWLER
  # This function traverses the options.nonOS tree to find any leaf option
  # that was created with 'lib.mkMandatoryOption'.
  # Returns a list of attribute paths (e.g. [ ["hostname"] ["hardware" "storage" "main"] ]).
  findMandatoryPaths = prefix: node:
    if node ? _type && node._type == "option" then
      # Base Case: We found an option. Check if our custom mandatory flag is on the type.
      if node ? type && node.type ? _mandatory && node.type._mandatory
      then [ prefix ]
      else [ ]
    else if isAttrs node then
      # Recursive Case: This is an attribute set (a category).
      # Walk its children, but skip internal metadata to avoid infinite loops.
      let
        childNames = filter (n: ! isInternal n) (attrNames node);
      in
      concatLists (map (n: findMandatoryPaths (prefix ++ [ n ]) node.${n}) childNames)
    else [ ];

  # Calculate all mandatory paths starting from the root of our config.
  mandatoryPaths = findMandatoryPaths [ ] options.nonOS;

  # 3. UNKNOWN KEY VALIDATION
  # Here we identify keys present in the TOML configuration (config.nonOS)
  # that have no matching definition in any of our modules (options.nonOS).

  providedKeys = attrNames config.nonOS;

  # A key is "Defined" if it exists in the option tree and isn't internal metadata.
  isDefined = name: (builtins.hasAttr name options.nonOS) && (! isInternal name);

  unknownKeys = filter (key: ! isDefined key) providedKeys;

in {
  config = {
    # ASSERTIONS: Fail the build with a helpful message if mandatory fields are missing.
    assertions = map (path: {
      assertion = (attrByPath path null config.nonOS) != null;
      message = "NonOS Error: The mandatory configuration field 'nonOS.${concatStringsSep "." path}' is missing in your TOML file.";
    }) mandatoryPaths;

    # WARNINGS: Notify the user about unrecognized keys (helps catch typos).
    warnings = map (key:
      "NonOS Warning: Unknown key '${key}' found in your TOML configuration. It will be ignored."
    ) unknownKeys;
  };
}
