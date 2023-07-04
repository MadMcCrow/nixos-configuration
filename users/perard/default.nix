# perard.nix
# 	my User
{ pkgs, config, ... }:
{
  # nixos config
  users.users.perard = {
    uid = 1000;
    description = "Noé Perard-Gayot";
    group = "users";
    extraGroups = [ "wheel" "steam" "flatpak" ];
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
    isNormalUser = true;

  };
    # home manager configuration
    home-manager.users.perard = import ./home.nix;
}
