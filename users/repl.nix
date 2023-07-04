# users/repl.nix
{}:
let
  config = {};
  pkgs = import <nixpkgs> {};
  # merge list of Attribute sets (of users)
  users = import ./users.nix {inherit pkgs config;};

in {

  # implementation
  config = {
    # merge all users
    users = {
      users = users.configUsers;
      mutableUsers = true; # allow manually adding users
    };
    # merge all the home-manager configs
    home-manager.users = users.home-managerUsers;
  };
}
