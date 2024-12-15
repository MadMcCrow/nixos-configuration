# users/default.nix
# 	users for nixos and Darwin systems
#   TODO : clean and simplify
#   TODO : option to enable or disable users
{ home-manager, config, ... }:
let
  # TODO : rename and change how they are merged
  users = [ ./perard ];
in
{
  # import users
  imports = [ home-manager.nixosModules.home-manager ] ++ users;

  config = {
    # our users uses zsh so we need to enable those
    programs.zsh.enable = true;
    # home manager config users :
    home-manager = {
      useGlobalPkgs = false; # TODO : move to true and remove nixpkgs options from HM
      useUserPackages = true;
      # extraModules = [ plasma-manager.homeManagerModules.plasma-manager ];
      # extraSpecialArgs = { pkgs = pkgs-latest; };
    };
  };
}
