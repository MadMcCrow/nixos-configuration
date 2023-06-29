# users/darwin.nix
# 	users for MacOS systems
{ config, pkgs, ... }:
with builtins;
let
  # merge list of Attribute sets (of users)
  users = import ./users.nix {inherit pkgs;};

  # minimal config users
  darwinUser = mapAttrs (name : value : {inherit name; home = "/Users/${name}";}) users.configUsers;
  # home manager users with specific homeDirectory
  home-managerUsers = mapAttrs (name: value : (value // {home = value.home //{ homeDirectory= "/Users/${name}";};})) users.home-managerUsers;

in {
  config.users.users = darwinUser;
  # only Home manager supported in macOS
  config.home-manager.users = home-managerUsers;
}
