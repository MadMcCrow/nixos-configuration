# users/merge.nix
# a function to help merge list of users
{ key , list } :
let
# split "a.b" into ["a" "b"]
splitAttr = name : strings.splitString "." name;

  # recursive versions of hasAttr and getAttr
  recurseHas = list: index: set: if ((length list) <= index) then true else if (hasAttr (elemAt list index) set) then (recurse list (index + 1) set) else false;
  recurseGet = list: index: set: if ((length list) <= index) then set  else if (hasAttr (elemAt list index) set) then (recurseGet list (index + 1) (getAttr (elemAt list index) set)) else {};

  
  # merger function
  mergeAttrs = list : index: set : if ((length list) <= index) then set else mergeAttrs list (index + 1) (set // (elemAt list index));
  mergeAny = list : let last = elemAt list ((length list) - 1); in
  if isAttrs last then (mergeAttrs list 0 (elemAt list 0))
  else if isList last then concatLists list
  else last;
in 
# merge list of Attribute sets (of users)
mergeAny (map (x : recurseGet (splitAttr key) 0 x) list)

