# users/default.nix
# 	Allow definition of user lists
{ config, pkgs, lib, home-manager, ... }:
with builtins;
with lib;
let
  cfg = config.userList;

  # Set a user 
  # Todo : make a better function
  mkUser = args@{ name, extraOptions, ... }:
    let nixArgs = removeAttrs args [ "extraOptions" ];
    in {
      isNormalUser = true;
      home = "/home/${name}";
      homeMode = "700";
      shell = pkgs.zsh;
    } // nixArgs;

  # set home manager :
  mkHMUser = userArgs@{ ... }:
    sysArgs@{ lib, pkgs, ... }:
    let
      args = sysArgs // userArgs.extraOptions;
      hm = import ./home-manager args;
    in {
      home.packages = hm.packages;
      home.stateVersion = "22.11";
      programs = hm.programs;
    };

  # for each 
  listOfAttrToAttr = f: l:
    listToAttrs (map (x: {
      name = (getAttr "name" x);
      value = (f x);
    }) l);

  nixos-users = listOfAttrToAttr mkUser cfg;
  hm-users = listOfAttrToAttr mkHMUser cfg;

in {
  # imports
  imports = [ home-manager.nixosModule home-manager.nixosModules.home-manager ];

  # interface
  options.userList = mkOption {
    type = types.listOf types.attrs;
    default = [ ];
    description = "list of users";
  };

  # implementation
  config = mkIf (cfg != [ ]) {
    # merge all users
    users = {
      users = nixos-users;
      mutableUsers = true; # allow manually adding users
    };
    home-manager.users = hm-users;
  };
}
