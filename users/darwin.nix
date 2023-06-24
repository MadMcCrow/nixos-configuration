# users/darwin.nix
# 	users for MacOS systems
{ config, pkgs, home-manager, ... }:
let
  # me !
  perard = import ./perard { inherit pkgs; };

  userList = [ perard ];

  # merge list of Attribute sets (of users)
  mergeSubSets = import ./merge.nix;

in {

  # import HM
  imports = [ home-manager.darwinModules.home-manager ];

  # implementation
  config = {
    # only Home manager supported in macOS
    home-manager.users = mergeSubSets "home-manager.users" userList;
  };
}
