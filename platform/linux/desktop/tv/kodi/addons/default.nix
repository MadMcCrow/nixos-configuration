# addons/default.nix
# All addons for kodi
# TODO : Add https://github.com/sualfred/skin.embuary
{ pkgs, lib, kodiPkgs, ... }@args:
let addons = [ ./nm.nix ];
in lib.lists.flatten (map (x: import x args) addons)
