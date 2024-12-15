# import all linux modules :
{ lanzaboote, ... }:
{
  imports = [
    # the base linux config :
    ./config.nix
    # dependancy :
    lanzaboote.nixosModules.lanzaboote
  ];
}
