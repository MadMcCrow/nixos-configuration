# users/darwin.nix
# 	users for MacOS systems
{ config, pkgs, home-manager, ... }:
with builtins;
with pkgs.lib;
let
  # me !
  perard = import ./perard { inherit pkgs; };
  userList = [ perard ];

  # helper functions
  mapFilter = k: l: map (x: getAttr k x) (filter (x: hasAttr k x) l);
  mergeSubSets = k: l:
    listToAttrs
    (builtins.mapAttrs (name: value: { inherit name value; }) (mapFilter k l));

in {

  # import HM
  imports = [ home-manager.darwinModules.home-manager ];

  # implementation
  config = {
    # only Home manager supported in macOS
    home-manager.users = mergeSubSets "home-manager.users" userList;
  };
}
