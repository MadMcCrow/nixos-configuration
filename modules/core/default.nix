# all my linux modules:
{ _ } :
{
  imports = [
    ./config.nix      # base linux config
    ./filesystems.nix # formating the OS
    ./autowake.nix    # start and stop on a timer
    ./update.nix      # automatic updates
  ]
}
