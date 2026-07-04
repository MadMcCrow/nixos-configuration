# modules.nix
# expose boilerplate function to add to your system
{
  lib,
  ...
} :
let
in
{
  nonOS = {curpos, config , options ? {} } :
  let
  pathlist = throw curpos;
  in {
    # cfg getter
    cfg = lib.attrByPath pathlist config;
    # set options
    options = optAttr : lib.sedAttrByPath pathlist optAttr;
  };
}
