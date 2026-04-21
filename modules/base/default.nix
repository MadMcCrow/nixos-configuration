# all my linux modules:
_ : {
  imports = [
    ./boot.nix
    ./desktop.nix
    ./update.nix # automatic updates
    ./users.nix # setting up users
  ];
}
