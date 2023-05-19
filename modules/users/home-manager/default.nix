# home-manager/default.nix
# 	function to enable all our tools from HM
args@{ pkgs, ... }:
with builtins;
let
  lib = pkgs.lib;
  submodules = [
     ./shell.nix 
     ./git.nix ];
     #./vs-code.nix ];

  # get all modules :
  imports = map (p: import p args) submodules;

  # helper function
  condGet = n: d: s: (if (hasAttr n s) then getAttr n s else d);
  listWithAttr = n: d: l: map (v: condGet n d v) l;

  # takes a property name and all the values and get 
  #mergePrograms = l: lib.fold (attrset: acc: lib.recursiveUpdate attrset acc) {} l;
  mergePrograms = l: foldl' (x: y: x // y) { } l;

in {

  # merge all packages
  packages = [ home-manager ] ++ concatLists (listWithAttr "packages" [ ] imports);

  # merge all programs
  programs = mergePrograms (listWithAttr "programs" { } imports);

}
