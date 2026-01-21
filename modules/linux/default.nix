# all my linux modules:
{ _ } :
{
  imports = [
    ./config.nix      # base linux config
    ./filesystems.nix # formating the OS
    ./update.nix      # automatic updates
    lanzaboote.nixosModules.lanzaboote
  ]
}
