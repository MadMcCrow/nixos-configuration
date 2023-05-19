# users/default.nix
# 	Allow definition of user lists
{ config, pkgs, lib, home-manager, ... }:
with builtins;
with lib;
let
  cfg = config.userList;

  # Set a user 
  # Todo : make a better function
  mkUser = args@{ name, description, uid, initialHashedPassword, ... }:
    {
      inherit description uid name initialHashedPassword;
      isNormalUser = true;
      home = "/home/${name}";
      homeMode = "700";
      shell = pkgs.zsh;
    };

  # set home manager :
  mkHMUser = args@{ ... }:
    let hm = import ./home-manager args;
    in {
      home.packages = hm.packages;
      home.stateVersion = "23.05";
      programs = hm.programs;
    };

  listOfAttrToAttr = f: l:
    listToAttrs (map (x: {
      name = (getAttr "name" x);
      value = (f x);
    }) l);

  nixos-users = listOfAttrToAttr mkUser cfg;
  hm-users = listOfAttrToAttr mkHMUser cfg.list;

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
