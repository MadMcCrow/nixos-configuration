# users/default.nix
# 	users for nixos and Darwin systems
#   TODO : clean and simplify
#   TODO : option to enable or disable users
{ config, pkgs, lib, plasma-manager, ... } @args :
let
  # list of users :
  users = [ ./perard ];


  # merge users :
  usersConfig = lib.attrsets.zipAttrsWith
  (name: value: builtins.foldl' (a: b: a//b) {} value)
  (map (x: (import x args)) users);

in {
  config = ({
    # home manager config users :
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraModules = [
            plasma-manager.homeManagerModules.plasma-manager
          ];
    };
  } // usersConfig);
}
