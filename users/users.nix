# users/merge.nix
# a function to help merge list of users
{pkgs} :
with builtins;
with pkgs;
let

  users = [./perard];

  # FUNCTIONS

  # split "a.b" into ["a" "b"]
  splitAttr = name : lib.strings.splitString "." name;

  # recursively get variables in lists
  recurseGet = l: i: s: if !(i < (length l)) then s else if (hasAttr (elemAt l i) s) then (recurseGet l (i + 1) (getAttr (elemAt l i) s)) else {};

  # merger function
  cat = a : b : if (isAttrs a) then (a // b) else if (isList a) then concatLists [a b] else b;
  recMerge = l : i: s : if (i < (length l)) then recMerge l (i + 1) (cat s (elemAt l i)) else s;
  merge = l : recMerge l 0 (elemAt l 0);

  # function to merge variables
  keyMerge = key : list : merge (map (x : recurseGet (splitAttr key) 0 x) list);

  # imports
  userList =  map (x :  import x { inherit pkgs; }) users;

in
{
  configUsers       = keyMerge "users.users" userList;
  home-managerUsers = keyMerge "home-manager.users" userList;
}



