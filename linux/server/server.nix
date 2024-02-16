# server.nix
#   base config for a nixos server
{ config, pkgs, lib, ... }:
let
  inherit (lib) mkDefault;
  mkPrio = value: lib.mkOverride 100 value;
in lib.mkIf config.nixos.server.enable {

  services.xserver = { enable = mkDefault false; };

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
    loader.systemd-boot.configurationLimit = mkPrio 10;
    consoleLogLevel = mkPrio 4; # we wanna know everything
  };

  security.apparmor.enable = true;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = mkDefault "powersave";

  # prevent any sleep/hibernation.
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  systemd.services.NetworkManager-wait-online.enable = mkPrio true;
  systemd.services.systemd-fsck.enable = mkPrio true;

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
  documentation.nixos.enable = mkDefault true;

}
