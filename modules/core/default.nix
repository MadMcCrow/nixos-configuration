{ ... }: {
  imports = [
    ./boot.nix
    ./network.nix
    ./system.nix
    ./users.nix # user management
  ];
}
