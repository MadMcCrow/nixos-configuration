# guest.nix
# 	a custom, temporary user for whomever wants to be able to log on this computer
{ config, pkgs, home-manager, ... }: {

  # imported thanks to specialArgs
  #imports = [ home-manager.nixosModule ];

  # User on tmpfs
  fileSystems."/home/guest" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=764" ];
  };

  # user setup
  users.users.guest = {
    description = "Guest";
    extraGroups = [ "guests" ];
    isNormalUser = true;
    initialPassword = "";
    home = "/home/guest";
    uid = 1001;
  };
}
