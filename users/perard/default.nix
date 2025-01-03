# perard.nix
# TODO : generalise :
# 	my User
{ pkgs, lib, ... }:
let
  isLinux = lib.strings.hasSuffix "linux" pkgs.system;
in
{
  # nixos config
  config = {

    users.users.perard = lib.mkMerge [
      {
        uid = 1000;
        description = "Noé Perard-Gayot";
        shell = pkgs.zsh;
      }
      (lib.attrsets.optionalAttrs isLinux {
        group = "users";
        extraGroups = [
          "wheel"
          "steam"
          "flatpak"
          "networkmanager"
          "docker"
        ];
        initialHashedPassword = "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
        isNormalUser = true;
      })
      (lib.attrsets.optionalAttrs (!isLinux) { home = "/Users/perard"; })
    ];

    home-manager.users.perard =
      if isLinux then
        (import ./home/nixos.nix)
      else
        (import ./home/darwin.nix);
  };
}
