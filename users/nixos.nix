# users/nixos.nix
# 	users for Nixos systems
#   TODO : add option for each user
#   TODO : add back option for guest user
{ config, pkgs, home-manager, ... }:
let
  # merge list of Attribute sets (of users)
  users = import ./users.nix {inherit pkgs;};

in {

  # import HM
  imports = [ home-manager.nixosModule home-manager.nixosModules.home-manager ];

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
