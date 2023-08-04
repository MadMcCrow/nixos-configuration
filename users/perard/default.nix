# perard.nix
# 	my User
{ pkgs, lib, ... }:
with builtins;
with lib;
let
# TODO : make those key generated for user !
id_rsa_pub_AF = "";
id_rsa_pub_NUC = "";
in
{
  # nixos config
  users.users.perard = {
    uid = 1000;
    description = "Noé Perard-Gayot";
    group = "users";
    extraGroups = [ "wheel" "steam" "flatpak" "networkmanager" ];
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
    isNormalUser = true;

    openssh.authorizedKeys.keys = [id_rsa_pub_AF id_rsa_pub_NUC];

    # use zsh if zsh is available
    shell = pkgs.zsh;

  };
    # home manager configuration
    home-manager.users.perard = import ./home.nix ;
}
