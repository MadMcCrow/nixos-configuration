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

    options.nonOS = {
      x.a = lib.mkOption { type = lib.types.str // {_mandatory = true;};
          description = "sort";
      };
      a = lib.mkOption { type = lib.types.str;
          description = "bobo";
      };
      b = let base = lib.mkEnableOption "mandatorytest"; in
      base // { type = base.type // {_mandatory = true;}; };
    };


    filterOptions = attrs :
    filter (k: (optAttr attrs "${k}.type._mandatory") == true ) (collectOptions attrs);
in
{
  options = options.nonOS;
  optAttr = optAttr ;
  opt = k : optAttr options.nonOS k;
  l = collectOptions options.nonOS;
  m = filterOptions options.nonOS;
}
