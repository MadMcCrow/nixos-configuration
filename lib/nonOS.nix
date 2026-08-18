# nonOS.nix
# helper attrset for modules;
inputs@{
  self,
  lib,
  ...
}:
with builtins;
let
  version = import ./version.nix inputs;

  inherit (version) name;

  # filter globals out of attrs
  filterGlobals = neg: attrs: lib.filterAttrs (n: _: (lib.hasPrefix "_" n) == neg) attrs;

  mkPrio = lib.mkOverride 990; # mkDefault but higher priority


in {
    # provide values
    inherit version;

    inherit mkPrio;

    # added packages
    pkgs = import (self + "/packages") inputs;

    mod =
      prefix: config:
      let
        pl = lib.optionals (prefix != "") (lib.splitString "." prefix);
      in
      rec {
        # cfg getter gets globals and specific
        cfg = (filterGlobals true config.${name}) // (lib.attrByPath pl { } config.${name});

        # set options :
        mkOptions = optAttr: {
          ${name} =
            # add globals
            (filterGlobals true optAttr)
            # and then we add all the other attribute by their path prefixed
            // (lib.setAttrByPath pl (
              filterGlobals false optAttr
              // {
                enable =
                  let
                    optPath = lib.concatStringsSep "." ([ name ] ++ pl);
                  in
                  lib.mkEnableOption optPath // { default = true; };
              }
            ));
        };
        # is this module enabled, recursive
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
          config.${name}.enable && isEnabledAncestor pl;
        # set config :
        mkConfig = c: lib.mkIf enabled (mkPrio c);
      };
  };
