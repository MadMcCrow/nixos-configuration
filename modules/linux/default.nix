# import all linux modules :
{ lanzaboote, ... }:
{
  imports = [
    # the base linux config :
    ./config.nix
    # auto-update script :
    ./update.nix
    # dependancy :
    lanzaboote.nixosModules.lanzaboote
  ];
}
