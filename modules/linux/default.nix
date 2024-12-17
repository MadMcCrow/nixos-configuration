# import all linux modules :
{ lanzaboote, ... }:
{
  imports = [
    # the base linux config :
    ./config.nix
    # auto-update script :
    ./update
    # dependancy :
    lanzaboote.nixosModules.lanzaboote
  ];
}
