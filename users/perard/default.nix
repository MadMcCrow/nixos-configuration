# perard.nix
# 	my User
{ pkgs }:
with builtins;
with pkgs.lib;
let
  # submodules
  modules = [ ./git.nix ./firefox.nix ./vs-code.nix ./zsh.nix ];
  
  # helper functions
  cat = a : b : if (isAttrs a) then (a // b) else if (isList a) then concatLists [a b] else b;
  recMerge = l : i: s : if (i < (length l)) then recMerge l (i + 1) (cat s (elemAt l i)) else s;
  merge = l : recMerge l 0 (elemAt l 0);
  filterMap = k: l :  map (x : getAttr k x) (filter (x : hasAttr k x) l);

  # modules values
  home-manager =  map (x: import x { inherit pkgs; }) modules;
  packages = merge (filterMap "packages" home-manager);
  programs = merge (filterMap "programs" home-manager);

  flatpakGroup = if config.nixos.flatpak.enable then ["flatpak"] else [];

in {

  # nixos config
  users.users.perard = {
    uid = 1000;
    description = "Noé Perard-Gayot";
    group = "users";
    extraGroups = [ "wheel" "steam" ] ++ flatpakGroup ;
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
    isNormalUser = true;

  };

  # home manager
  home-manager.users.perard = {
    home =  {
      username = "perard";
      inherit packages;
      stateVersion = "23.05";
    };
    inherit programs;
  };

}
