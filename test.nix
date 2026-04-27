with builtins;
let

pkgs = import <nixpkgs> {};
inherit (pkgs) lib;

optAttr = a: k: lib.attrByPath (lib.splitString "." k) null a;

collectOptions = attrs:
let
  # check option
  go = path: a:
    builtins.concatMap
      (key:
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


  args = {
    inherit pkgs;
    inherit lib;
    config = {};
    self = ./.;
  };
  modules = lib.foldl' (a: b: lib.recursiveUpdate a b) {} (map (x: import x args)[
    modules/core/system.nix
    modules/core/users.nix
    modules/hardware/cpu.nix
  ]);


    filterOptions = attrs :
    filter (k: (optAttr attrs "${k}.type._mandatory") == true ) (collectOptions attrs);

      options =  modules.options;
in
{
  inherit options;
  optAttr = optAttr ;
  opt = k : optAttr options.nonOS k;
  l = collectOptions options.nonOS;
  m = filterOptions options.nonOS;
}
