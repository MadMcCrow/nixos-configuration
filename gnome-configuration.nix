# Nixos Gnome Desktop environment settings
{ config, pkgs, lib, ... }: {

# enable GUI
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    desktopManager.xterm.enable = false;
    # GDM :
    displayManager = {
      gdm = {
        enable = true;
        wayland = true; # Wayland
      };
    };
    # use Gnome
    desktopManager.gnome.enable = true;
  };
  programs.xwayland.enable = true;

  # Gnome
  environment.gnome.excludePackages = with pkgs; [
    gnome.gnome-weather
    gnome-tour
    gnome-photos
    gnome.simple-scan
    gnome.gnome-music
    gnome.epiphany
    gnome.totem
    gnome.yelp
    gnome.cheese
    gnome.gnome-characters
    orca
  ];
  
  

  # disable unecessary services 
  services.gnome = {
    chrome-gnome-shell.enable = false;
    tracker-miners.enable = false;
    tracker.enable = false;
    gnome-online-miners.enable = lib.mkForce false;
  };

  # enable DConf to edit gnome configuration
  programs.dconf.enable = true;

  # systray icons
  environment.systemPackages = with pkgs; [ gnomeExtensions.appindicator ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
