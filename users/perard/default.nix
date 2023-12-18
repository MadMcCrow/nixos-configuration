# perard.nix
# 	my User
{ pkgs, lib, ... }:
let
  isLinux = (lib.strings.hasSuffix "linux" pkgs.system);
  # TODO : make those key generated for user !
  id_rsa_pub_AF = "";
  id_rsa_pub_NUC = "";
in {
  # nixos config
  users.users.perard = lib.mkMerge [
    {
      uid = 1000;
      description = "Noé Perard-Gayot";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ id_rsa_pub_AF id_rsa_pub_NUC ];
    }
    (lib.attrsets.optionalAttrs isLinux {
      group = "users";
      extraGroups = [ "wheel" "steam" "flatpak" "networkmanager" ];
      initialHashedPassword =
        "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
      isNormalUser = true;
    })
    (lib.attrsets.optionalAttrs (!isLinux) { home = "/Users/perard"; })
  ];

  # home manager configuration
  home-manager.users.perard =
    if isLinux then (import ./home/nixos.nix) else (import ./home/darwin.nix);
}
