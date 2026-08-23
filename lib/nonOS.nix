# nonOS.nix
# helper attrset for modules;
inputs@{
  self,
  lib,
  ...
}:
with builtins;
rec {
  # provide values and shortcuts
  inherit inputs;
  meta = (import ./meta.nix inputs);
  inherit (meta) name;
  mkPrio = lib.mkOverride 990; # mkDefault but higher priority

  mod =
    prefix: config:
    let
      # filter globals out of attrs
      filterGlobals = neg: attrs: lib.filterAttrs (n: _: (lib.hasPrefix "_" n) == neg) attrs;
      pl = lib.optionals (prefix != "") (lib.splitString "." prefix);

      # is this module enabled, recursive
      enabled =
        let
          isEnabledAncestor =
            p:
            let
              node = lib.attrByPath (p ++ [ "enable" ]) null config.${meta.name};
            in
            if node == false then
              false
            else if p == [ ] then
              true
            else
              isEnabledAncestor (lib.init p);
        in
        config.${name}.enable && isEnabledAncestor pl;
    in
    {
      inherit enabled;

      pkgs = self.packages.${config.nixpkgs.hostPlatform.system};

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

      # set config :
      mkConfig = c: lib.mkIf enabled c;
    };
}
