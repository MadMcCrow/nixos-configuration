# dconf.nix
# 	security dconf settings
{ config, pkgs, lib, ... }:
let

  dconf-profile = {
    # /etc/dconf/profile/user
    profile = ''
      user-db:user
      system-db:local
    '';
    # /etc/dconf/db/local.d/00-block
    block = ''
      [org/gnome/desktop/lockdown]
      disable-save-to-disk=true
      disable-printing=true
      disable-command-line=true
    '';
    # /etc/dconf/db/local.db/locks/filesaving
    block-lock = ''
      /org/gnome/desktop/lockdown/disable-save-to-disk
      /org/gnome/desktop/lockdown/disable-printing
      /org/gnome/desktop/lockdown/disable-command-line
    '';
  };

in {

}
