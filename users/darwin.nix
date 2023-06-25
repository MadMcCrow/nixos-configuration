# users/darwin.nix
# 	users for MacOS systems
{ config, pkgs, home-manager, ... }:
let
  # merge list of Attribute sets (of users)
  users = import ./users.nix {inherit pkgs;};

in {

  # import HM
  imports = [ home-manager.darwinModules.home-manager ];

  # implementation
  config = {
    # only Home manager supported in macOS
    home-manager.users = users.home-managerUsers;
  };
}
