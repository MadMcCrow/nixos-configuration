# users/default.nix
# 	users for nixos and Darwin systems
#   TODO : clean and simplify
#   TODO : option to enable or disable users
{ config, pkgs, pkgs-latest, ... }: {
  # import users
  imports = [ ./perard ];

  config = {
    # home manager config users :
    home-manager = {
      # useGlobalPkgs = true;
      useUserPackages = true;
      # extraModules = [ plasma-manager.homeManagerModules.plasma-manager ];
      # extraSpecialArgs = { pkgs = pkgs-latest; };
    };
  };
}
