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


  # helper functions
  recurseHas = list: index: set: if ((length list) <= index) then true else if (hasAttr (elemAt list index) set) then (recurse list (index + 1) set) else false;
  recurseGet = list: index: set: if ((length list) <= index) then set  else if (hasAttr (elemAt list index) set) then (recurseGet list (index + 1) (getAttr (elemAt list index) set)) else {};

  listOfUserAttributes = key : list : map (x : recurseGet key 0 x) list;

  mergeSubSets =  key : list : listToAttrs ( map ( { x, y } @ value: { name = x; inherit value; } ) (listOfUserAttributes key list) ); 

in {

  # import HM
  imports = [ home-manager.nixosModule home-manager.nixosModules.home-manager ];

  # implementation
  config = {
    # merge all users
    users.users = listOfUserAttributes "users.users";

    # should we allow this ?
    users.mutableUsers = true; # allow manually adding users

    # merge all the home-manager configs
    home-manager.users = mergeSubSets "home-manager.users" userList;
  };
}
