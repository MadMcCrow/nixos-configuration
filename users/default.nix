# users/default.nix
# 	users for nixos and Darwin systems
#   TODO : clean and simplify
args@{ config, pkgs, lib, firefox-gnome-theme, ... }:
with builtins;
with lib;
let
  # list of users :
  users = [ ./perard ];

  # split "a.b" into ["a" "b"]
  splitAttr = name: strings.splitString "." name;

  # recursively get variables in lists
  recurseGet = l: i: s:
    if !(i < (length l)) then
      s
    else if (hasAttr (elemAt l i) s) then
      (recurseGet l (i + 1) (getAttr (elemAt l i) s))
    else
      { };

  # merger function
  cat = a: b:
    if (isAttrs a) then
      (a // b)
    else if (isList a) then
      concatLists [ a b ]
    else
      b;
  recMerge = l: i: s:
    if (i < (length l)) then recMerge l (i + 1) (cat s (elemAt l i)) else s;
  merge = l: recMerge l 0 (elemAt l 0);

  # function to merge variables
  keyMerge = key: list: merge (map (x: recurseGet (splitAttr key) 0 x) list);

  # imports
  userList = map (x: import x args) users;

  # merge users :
  configUsers = keyMerge "users.users" userList;
  home-managerUsers = keyMerge "home-manager.users" userList;

  # only M1 supported for now
  isDarwin = pkgs.system == "aarch64-darwin";

  # minimal config users
  darwinUser = mapAttrs (name: value: {
    inherit name;
    home = "/Users/${name}";
  }) configUsers;

  darwinHM = mapAttrs ( name: value:
    let 
    homeValue = value args;
    in 
    (args :
    homeValue // { home = homeValue.home // { homeDirectory = "/Users/${name}"; }; }))
    home-managerUsers;

in {
  config = {
    # default nix config users :
    users = {
      users = if isDarwin then darwinUser else configUsers;
      # mutableUsers = true;
    };

    # home manager config users : 
    home-manager = {
      extraSpecialArgs = {inherit firefox-gnome-theme;};
      useGlobalPkgs = true;
      useUserPackages = true;
      users = if isDarwin then darwinHM else home-managerUsers;
    };
  };
}
