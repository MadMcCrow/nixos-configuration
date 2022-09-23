# flatpak
#
# TODO : use same persisting system as in persist.nix
{ inputs, lib, config, pkgs, ... }: {
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
  };

  # this folder is where the files will be stored (don't put it in tmpfs)
  environment.persistence."/nix/persist/flatpak" = {
    directories = [
      "/var/lib/flatpak" # bind mounted from /persist/flatpak/var/lib/flatpak to /var/lib/flatpak
    ];
  };
}
