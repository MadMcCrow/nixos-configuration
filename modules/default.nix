# all my linux modules:
{ _ }: {
  imports = [
    ./boot.nix
    ./filesystems.nix # formating the OS
    ./update.nix # automatic updates
    ./ssh.nix # ssh
    ./users.nix # setting up users
    lanzaboote.nixosModules.lanzaboote
  ];
}
