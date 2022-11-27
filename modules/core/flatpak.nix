# flatpak.nix
# 	Flatpak support for nixos
{ pkgs, config, lib, impermanence, ... }:
with builtins;
with lib;
let cfg = config.core.flatpak;
in {
  # interface
  options.core.flatpak.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "make flatpak available to our system";
  };
  # import thanks to specialArgs
  imports = [ impermanence.nixosModules.impermanence ];
  # configs
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

    environment.systemPackages = with pkgs; [
      libportal
      libportal-gtk3
      packagekit
    ];

    # enable package kit
    services.packagekit.enable = true;

    # this folder is where the files will be stored (don't put it in tmpfs/zfs clean partition)
    # bind mounted from /persist/flatpak/var/lib/flatpak to /var/lib/flatpak
    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/flatpak" ];
    };
  };
}
