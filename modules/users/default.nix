# users/default.nix
# 	Allow definition of user lists
{ config, pkgs, lib, home-manager, ... }:
with builtins;
with lib;
let
  cfg = config.myusers;

  # Set a user 
  # Todo : make a better function
  mkUser = args@{ name, description, uid, ... }:
    {
      inherit description uid name;
      isNormalUser = true;
      home = "/home/${name}";
      homeMode = "700";
      shell = pkgs.zsh;
    } // args;

  # set home manager :
  mkHMUser = args@{ ... }:
    let hm = import ./home-manager args;
    in {
      home.packages = hm.packages;
      home.stateVersion = "22.05";
      programs = hm.programs;
    };

  listOfAttrToAttr = f: l:
    listToAttrs (map (x: {
      name = (getAttr "name" x);
      value = (f x);
    }) l);
  nixos-users = listOfAttrToAttr mkUser cfg.list;
  #hm-users = listOfAttrToAttr mkHMUser cfg.list;

in {
  # imports
  imports = [ home-manager.nixosModule home-manager.nixosModules.home-manager ];
  # interface
  options.myusers = {
    # list of users to create
    list = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      description = "list of users";
    };
  };

  # implementation
  config = mkIf (cfg.list != [ ]) {
    # merge all users
    users = {
      users = nixos-users;
      # allow manually adding users during runtime;
      mutableUsers = true;
    };
    #home-manager.users = hm-users;
  };
}
