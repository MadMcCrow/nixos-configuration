# guest.nix
# 	a custom, temporary user for whomever wants to be able to log on this computer
{ config, pkgs, home-manager }: {

  # imported thanks to specialArgs
  imports = [ home-manager.nixosModule ];

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "guests" ];
    home = "/home/guest";
    homeMode = "764";
    uid = 1001;
  };
}
