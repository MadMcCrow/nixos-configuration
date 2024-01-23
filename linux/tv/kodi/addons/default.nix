# addons/default.nix
# All addons for kodi
# TODO : Add https://github.com/sualfred/skin.embuary
{ pkgs, lib, kodi, ... }@args:
let addons = [./osmc.nix ];
in lib.lists.flatten (map (x: import x args) addons)
