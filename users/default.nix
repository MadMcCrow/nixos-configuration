# users/default.nix
# 	users for nixos and Darwin systems
#   TODO : clean and simplify
args @ { config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # list of users :
  users = [./perard];

  # split "a.b" into ["a" "b"]
  splitAttr = name : strings.splitString "." name;

  # recursively get variables in lists
  recurseGet = l: i: s: if !(i < (length l)) then s else if (hasAttr (elemAt l i) s) then (recurseGet l (i + 1) (getAttr (elemAt l i) s)) else {};

  # merger function
  cat = a : b : if (isAttrs a) then (a // b) else if (isList a) then concatLists [a b] else b;
  recMerge = l : i: s : if (i < (length l)) then recMerge l (i + 1) (cat s (elemAt l i)) else s;
  merge = l : recMerge l 0 (elemAt l 0);

  # function to merge variables
  keyMerge = key : list : merge (map (x : recurseGet (splitAttr key) 0 x) list);

  # imports
  userList =  map (x :  import x args ) users;

  # merge users :
  configUsers       = keyMerge "users.users" userList;
  home-managerUsers = keyMerge "home-manager.users" userList;

  # only M1 supported for now
  isDarwin = pkgs.system == "aarch64-darwin";

  # minimal config users
  darwinUser = mapAttrs (name : value : {inherit name; home = "/Users/${name}";}) configUsers;
  darwinHM   = mapAttrs (name: value : (value // {home = value.home //{ homeDirectory= "/Users/${name}";};})) home-managerUsers;

in {

  config = {
    users.users = if isDarwin then darwinUser else configUsers;
    users.mutableUsers = true;
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users =if isDarwin then darwinHM else home-managerUsers;
  };
}
