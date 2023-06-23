# perard.nix
# 	my User
{ pkgs }:
with builtins;
with pkgs.lib;
let
  # submodules
  args = { inherit pkgs; };
  git = import ./git.nix args // {
    gitEmail = "noe.perard+git@gmail.com";
    gitUser = "MadMcCrow";
  };
  firefox = import ./firefox.nix args;
  vs-code = import ./vs-code.nix args;
  zsh = import ./zsh.nix args;
  modules = [ firefox vs-code zsh git ];

  # helper function
  mapFilter = k: l: map (x: getAttr k x) (filter (x: hasAttr k) l);
  # get packages from sets
  mergePackages = l: concatLists (mapFilter "packages" l);
  # get programs from sets
  mergePrograms = l:
    listToAttrs (builtins.mapAttrs (name: value: { inherit name value; })
      (mapFilter "programs" l));

in {

  # nixos config
  users.users.perard = {
    uid = 1000;
    description = "Noé Perard-Gayot";
    extraGroups = [ "wheel" "flatpak" "steam" ];
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
  };

  # home manager
  home-manager.users.perard = {
    home = {
      packages = mergePackages modules;
      stateVersion = "23.05";
    };
    programs = mergePrograms modules;
  };

}
