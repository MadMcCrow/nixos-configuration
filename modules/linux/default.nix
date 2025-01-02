# import all linux modules :
{ lanzaboote, home-manager, ... }:
{
  imports = [
    # the base linux config :
    ./config.nix
    # auto-update script :
    ./update
    # dependancy :
    lanzaboote.nixosModules.lanzaboote
    home-manager.nixosModules.home-manager
  ];
}
