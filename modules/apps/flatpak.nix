# flatpak.nix
# 	Flatpak support for nixos
{ config, pkgs, lib, impermanence, ... }:
with builtins;
with lib;
let cfg = config.apps.flatpak;
in {

  # interface
  options.apps.flatpak.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "make flatpak available to our system";
  };

  # import thanks to specialArgs
  imports = [ impermanence.nixosModules.impermanence ];

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
    xdg.portal = {
      enable = true;
      # deprecated : gtkUsePortal
      # this can cause issues as 
      # https://github.com/NixOS/nixpkgs/issues/135898
      # https://github.com/NixOS/nixpkgs/issues/156950
      # gtkUsePortal = true;
    };

    # this folder is where the files will be stored (don't put it in tmpfs/zfs clean partition)
    # bind mounted from /persist/flatpak/var/lib/flatpak to /var/lib/flatpak
    environment.persistence."/nix/persist/flatpak" = {
      directories = [ "/var/lib/flatpak" ];
    };
  };
}
