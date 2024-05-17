# perard.nix
# 	my User
{ pkgs, lib, pkgs-latest, ... }:
let isLinux = lib.strings.hasSuffix "linux" pkgs.system;
in {
  # nixos config
  users.users.perard = lib.mkMerge [
    {
      uid = 1000;
      description = "Noé Perard-Gayot";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBAdF/RB3J7J/5YZilb/tTT+gqdVIe/YmTA3OQOhuw8 perard@trantor"
      ];
    }
    (lib.attrsets.optionalAttrs isLinux {
      group = "users";
      extraGroups = [ "wheel" "steam" "flatpak" "networkmanager" "docker" ];
      initialHashedPassword =
        "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
      isNormalUser = true;
    })
    (lib.attrsets.optionalAttrs (!isLinux) { home = "/Users/perard"; })
  ];

  home-manager.users.perard =
    if isLinux then (import ./home/nixos.nix) else (import ./home/darwin.nix);
}
