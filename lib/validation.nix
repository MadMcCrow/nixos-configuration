# Validation of the TOML configuration
{
  pkgs,
  nonpkgs,
  lib,
  config,
  options,
  system,
  import-tree,
  self,
  tomlPath,
  ...
}:
with builtins;
let
  # import and build our derivation for valid keys.
  # this should be cached
  validKeys = nonpkgs.config-keys;

  # Load both files at eval time
  userConfig  = fromTOML (readFile tomlPath);
  knownSchema = fromTOML (readFile validKeys);

  known = lib.genAttrs knownSchema.known_options (k: true);

  # Flatten nested attrset to dotted paths
  flattenKeys = prefix: attrs:
    lib.concatLists (
      lib.mapAttrsToList (name: val:
        let path = if prefix == "" then name else "${prefix}.${name}"; in
        if lib.isAttrs val then flattenKeys path val
        else [ path ]
      ) attrs
    );

  userKeys = flattenKeys "" userConfig;

  # Split into known and unknown
  unknown = lib.filter (k: !(lib.hasAttr k known || isKnownPrefix k)) userKeys;

  # Accept keys whose prefix matches a known option (for freeform attrs)
  isKnownPrefix = key:
    let parts = lib.splitString "." key; in
    lib.any
      (i: lib.hasAttr (lib.concatStringsSep "." (lib.take i parts)) known)
      (lib.range 1 (lib.length parts));

in {
  # add a warning for evey unknown key
  config.warnings = map (
    key: "NonOS Warning: Unknown key '${key}' found in your TOML configuration. It will be ignored."
  ) unknown;
}
