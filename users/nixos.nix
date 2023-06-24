# users/nixos.nix
# 	users for Nixos systems
#   TODO : add option for each user
#   TODO : add back option for guest user
{ config, pkgs, home-manager, ... }:
with builtins;
with pkgs.lib;
let

  # me !
  perard = import ./perard { inherit pkgs; };

  userList = [ perard ];

  # merge list of Attribute sets (of users)
  mergeSubSets = import ./merge.nix;


in {

  # import HM
  imports = [ home-manager.nixosModule home-manager.nixosModules.home-manager ];

  # implementation
  config = {
    # merge all users
    users.users = mergeSubSets "users.users" userList;

    # should we allow this ?
    users.mutableUsers = true; # allow manually adding users

    # merge all the home-manager configs
    home-manager.users = mergeSubSets "home-manager.users" userList;
  };
}
