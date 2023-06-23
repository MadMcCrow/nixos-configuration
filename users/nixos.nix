# users/nixos.nix
# 	users for Nixos systems
#   TODO : add option for each user
#   TODO : add back option for guest user
{ config, pkgs, home-manager, ... }:
with builtins;
with pkgs.lib;
let
  # me !
  perard = import ./perard.nix { inherit pkgs; };
  userList = [ perard ];

  # helper functions
  mapFilter = k: l: map (x: getAttr k x) (filter (x: hasAttr k) l);
  mergeSubSets = s: l:
    listToAttrs
    (builtins.mapAttrs (name: value: { inherit name value; }) (mapFilter s l));

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
