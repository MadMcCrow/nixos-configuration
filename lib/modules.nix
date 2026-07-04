# modules.nix
# expose boilerplate function to add to your system
{
  lib,
  ...
} :
{
  # get the attribute path from __curpos
  modpathl = curpos : throw curpos;

  # gets the config prefixed by the path
  noncfg = config : pathl : lib.attrByPath pathl;


  #nonopt = options : pathl : lib.se
}
