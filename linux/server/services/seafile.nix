# seafile.nix
#   configuration for the seafile service container
{ config, pkgs, lib, ... }: {
  # seafile
  services.seafile = lib.mkIf config.nixos.server.seafile.enable {
    adminEmail = config.nixos.server.adminEmail;
    enable = true;
  };
}
