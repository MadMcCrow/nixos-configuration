# guest.nix
# 	a custom, temporary user for whomever wants to be able to log on this computer
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.users.guest;
in {
  options.users.guest.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable guest user";
  };

  # imported thanks to specialArgs
  #imports = [ home-manager.nixosModule ];

  config = lib.mkIf cfg.enable {
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
  };
}
