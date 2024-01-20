# server.nix
#   base config for a nixos server
{ config, pkgs, lib, ... }:
let mkPrio = value: lib.mkOverride 100 value;
in lib.mkIf config.nixos.server.enable {

  # TODO : maybe remove this
  services.xserver = { enable = mkPrio false; };

  # env :
  environment.defaultPackages = with pkgs; [
    smartmontools
    cachix
    vulnix
    age
    policycoreutils
  ];

  boot = {
    plymouth.enable = mkPrio false;
    supportedFilesystems = [ "ext4" "f2fs" "fat32" "zfs" ];

    # make sure to be able to start !
    loader.systemd-boot.configurationLimit = 10;
    consoleLogLevel = mkPrio 4; # we wanna know everything
  };

  security.apparmor.enable = true;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = mkPrio "powersave";

  systemd.services.NetworkManager-wait-online.enable = true;
  systemd.services.systemd-fsck.enable = true;

  # SSL :
  users.groups.ssl-cert.gid = 119;

  # serve nix store over ssh
  nix.sshServe.enable = true;

  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
    };
    #permitRootLogin = "yes";
  };

  system.nixos.tags = [ "Server" ];
  system.stateVersion = "23.11";
  documentation.nixos.enable = mkPrio true;

}
