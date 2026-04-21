# all my linux modules:
{ _ }: {
  imports = [
    ./boot.nix
    ./desktop.nix
    ./filesystems.nix # formating the OS
    ./update.nix # automatic updates
    ./users.nix # setting up users
  ];
}
