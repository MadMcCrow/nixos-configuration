# users/darwin.nix
# 	users for MacOS systems
{ config, pkgs, ... }:
with builtins;
let
  # merge list of Attribute sets (of users)
  users = import ./users.nix {inherit pkgs;};

  darwinUser = mapAttrs (name : value : {inherit name;}) users.configUsers;

in {

  # import HM
  #imports = [ home-manager.darwinModules.home-manager ];

  # TODO: should build with func
  config.users.users = darwinUser;
  # only Home manager supported in macOS
  config.home-manager.users = users.home-managerUsers;
}
