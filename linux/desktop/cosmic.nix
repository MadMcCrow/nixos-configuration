# cosmic.nix
# Cosmic Desktop Environment for nixOS.
# NOT SUPPORTED YET
{ config, pkgs-latest, lib, ... }:
with pkgs-latest;
let
  core = [
    cosmic-randr
    cosmic-comp
    cosmic-settings-daemon
    cosmic-osd
    cosmic-protocols
    xdg-desktop-portal-cosmic
  ];
  session = [ cosmic-session cosmic-greeter ];
  shell = [
    cosmic-panel
    cosmic-icons
    cosmic-notifications
    cosmic-applets
    cosmic-launcher
    cosmic-bg
    cosmic-workspaces-epoch
  ];
  tools =
    [ cosmic-term cosmic-edit cosmic-files cosmic-settings cosmic-screenshot ];
in {
  config = {
    environment.systemPackages = core ++ session ++ shell ++ tools;

  };
}
