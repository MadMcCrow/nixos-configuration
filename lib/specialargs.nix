# modules.nix
# use import-tree magic to make our custom TOML parser
inputs@{
  self,
  lib,
  ...
}:
with builtins;
with lib;
let
  version = import ./version.nix inputs;
in
{
  # helper function/attrset for modules;
  mod =
    prefix: config:
    let
      # option/config name
      prefixpath = optionals (prefix == "") (splitString "." prefix);
      pathlist = [ name ] ++ prefixpath;
      path = lib.string.join "." pathlist;
      # filter globals out of attrs
      filterGlobals = attrs: neg: filterAttrs (n: _: (hasPrefix "_" n) != neg) attrs;
      # test if this module is enabled
      enabled =
        let
          isEnabledAncestor =
            p:
            let
              node = lib.attrByPath (p ++ [ "enable" ]) null config.${name};
            in
            if node == false then
              false
            else if p == [ ] then
              true
            else
              isEnabledAncestor (lib.init p);
        in
        config.${name}.enable && isEnabledAncestor pathlist;
    in
    {
      # provide values
      inherit (version) version name status;
      inherit path;

      # cfg getter gets globals and specific
      cfg = (filterGlobals true config.${name}) // (attrByPath pathlist { } config.${name});
      # added libraries
      #lib = import ./options.nix inputs;
      # added packages
      pkgs = import ./packages.nix inputs;
      # set options :
      options = optAttr: {
        ${name} =
          # add globals
          (filterGlobals true optAttr)
          # and then we add all the other attribute by their path prefixed
          // (setAttrByPath pathlist (
            filterGlobals false optAttr
            // {
              enable = mkEnableOption "${name}.${path}" // {
                default = enabled;
              };
            }
          ));
      };
      # set config :
      mkConfig = cfg: mkIf enabled (mkOverride 990 cfg);
    };
}
