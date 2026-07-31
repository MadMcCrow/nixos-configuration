# modules.nix
# exposes all of our modules
inputs@{
  self,
  lib,
  ...
}:
with builtins;
let
  inherit (import ./version.nix inputs) name;

  # filter globals out of attrs
  filterGlobals = neg: attrs: lib.filterAttrs (n: _: (lib.hasPrefix "_" n) == neg) attrs;

  mkPrio = lib.mkOverride 990; # mkDefault but higher priority

  # helper attrset for modules;
  nonOS = {

    # provide values
    inherit (version) version name status;

    inherit mkPrio;

    # added packages
    pkgs = import ./packages.nix inputs;

    mod = prefix: config:
    let
      pl = (lib.optionals (prefix != "") (lib.splitString "." prefix));
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
          // (lib.setAttrByPath (lib.traceVal pl) (
            filterGlobals false optAttr
            // {
              enable = lib.mkEnableOption "${name}.${path}" // {
                default = true;
              };
            }
          ));
      };
      # is this module enabled, recursive
      enabled = pl:
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
                  isEnabledAncestor (init p);
            in config.${name}.enable && isEnabledAncestor pl;
      # set config :
      mkConfig = c: lib.mkIf enabled (mkPrio c);
    };
  };

manifest = import (self + "/modules/manifest.nix") (inputs // {inherit nonOS;});

in mapAttrs (k: v: ( _: { imports = v;}))
(manifest // { "default" = lib.concatAttrValues manifest;})
